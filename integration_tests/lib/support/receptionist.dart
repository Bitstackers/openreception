part of ort.support;

/**
 * Class modeling the domain actor "Receptionist".
 * Contains references to resources needed in order to make the actor perform
 * the actions described in the use cases.
 * Actions are outlined by public functions such as [pickup].
 */
class Receptionist {
  static final Logger log = new Logger('Receptionist');

  final model.User user;
  final Phonio.SIPPhone phone;
  final String authToken;

  Service.NotificationSocket notificationSocket;
  Service.CallFlowControl callFlowControl;
  Transport.Client _transport = null;

  Completer readyCompleter = new Completer();
  Queue<event.Event> eventStack = new Queue<event.Event>();

  Phonio.Call currentCall = null;

  Map toJson() => {
        'id': this.hashCode,
        'user': user,
        'auth_token': authToken,
        'phone': phone,
        'event_stack': eventStack.toList()
      };

  int get hashCode => user.id.hashCode;

  /// The amout of time the actor will wait before answering an incoming call.
  Duration answerLatency = new Duration(seconds: 0);

  /**
   * Default constructor. Provides an _uninitialized_ [Receptionist] object.
   */
  Receptionist(this.phone, this.authToken, this.user) {
    log.finest('Creating new Receptionist with ${phone.runtimeType} phone '
        'and account ${phone.defaultAccount.username}@'
        '${phone.defaultAccount.server} - ${phone.defaultAccount.password}');
  }

  /**
   * Perform object initialization.
   * Return a future that completes when the initialization process is done.
   * This method should only be called by once, and other callers should
   * use the [whenReady] function to wait for the object to become ready.
   */
  Future initialize(Uri callFlowUri, Uri notificationSocketUri) async {
    _transport = new Transport.Client();

    log.finest('Connecting to callflow on $callFlowUri');
    callFlowControl = new Service.CallFlowControl(
        callFlowUri, this.authToken, this._transport);

    if (this.readyCompleter.isCompleted) {
      this.readyCompleter = new Completer();
    }

    Transport.WebSocketClient wsc = new Transport.WebSocketClient();
    this.notificationSocket = new Service.NotificationSocket(wsc);

    final notifyUri =
        Uri.parse('${notificationSocketUri}?token=${this.authToken}');
    log.finest('Connecting websocket to $notifyUri');

    await wsc.connect(notifyUri);
    notificationSocket.onEvent.listen(_handleEvent,
        onDone: () => log.fine('$this closing notification listener.'));

    await phone.initialize();
    phone.eventStream.listen(this._onPhoneEvent,
        onDone: () => log.fine('$this closing event listener.'));
    await phone.autoAnswer(true);
    await phone.register();
    eventStack.clear();
    currentCall = null;

    readyCompleter.complete();
  }

  /**
   * Perform object teardown.
   * Return a future that completes when the teardown process is done.
   * After teardown is completed, the object may be initialized again.
   */
  Future teardown() {
    log.finest('Clearing state of $this');
    if (this._transport != null) {
      this._transport.client.close(force: true);
    }
    Future notificationSocketTeardown = this.notificationSocket == null
        ? new Future.value()
        : this.notificationSocket.close();

    this.callFlowControl = null;
    Future phoneTeardown = this.phone.teardown();

    return Future.wait([
      notificationSocketTeardown,
      phoneTeardown,
      new Future.delayed(new Duration(milliseconds: 10))
    ]).catchError((error, stackTrace) {
      log.severe(
          'Potential race condition in teardown of Receptionist, ignoring as test error, but logging it');
      log.severe(error, stackTrace);
    });
  }

  Future finalize() =>
      phone.ready ? teardown().then((_) => phone.finalize()) : phone.finalize();

  /**
   * Future that enables you the wait for the object to become ready.
   */
  Future ready() {
    if (this.readyCompleter.isCompleted) {
      return new Future.value(null);
    }

    return this.readyCompleter.future;
  }

  /**
   * Dumps the current event stack of the Receptionist to log stream.
   */
  void dumpEventStack() {
    log.severe('=== $this eventStack contents: ${this.eventStack}');
    this.eventStack.forEach(log.severe);
    log.severe('=== End of stack');
  }

  /**
   * Globally enable autoanswer on phone.
   */
  Future autoAnswer(bool enabled) => this.phone.autoAnswer(enabled);

  /**
   * Registers the phone in the PBX SIP registry.
   */
  Future registerAccount() {
    if (this.phone is Phonio.PJSUAProcess) {
      return (this.phone as Phonio.PJSUAProcess).registerAccount();
    } else if (this.phone is Phonio.SNOMPhone) {
      log.severe('Assuming that SNOM phone is already registered.');
      return new Future(() => null);
    } else {
      return new Future.error(new UnimplementedError(
          'Unable to register phone type : ' '${this.phone.runtimeType}'));
    }
  }

  /**
   * Transfers active [callA] to active [callB] via the
   * [CallFlowControl] service.
   */
  Future transferCall(model.Call callA, model.Call callB) =>
      this.callFlowControl.transfer(callA.id, callB.id);

  /**
   * Parks [call] in the parking lot associated with the user via the
   * [CallFlowControl] service. May optionally
   * set [waitForEvent] that will make this method wait until the notification
   * socket confirms the the call was sucessfully parked.
   */
  Future park(model.Call call, {bool waitForEvent: false}) async {
    Future parkAction = this.callFlowControl.park(call.id);

    model.Call validateCall(model.Call parkedCall) {
      expect(call.id, parkedCall.id);
      expect(
          call.answeredAt
              .difference(parkedCall.answeredAt)
              .inMilliseconds
              .abs(),
          lessThan(500));
      expect(call.arrived.difference(parkedCall.arrived).inMilliseconds.abs(),
          lessThan(500));
      expect(call.assignedTo, parkedCall.assignedTo);
      expect(call.callerId, parkedCall.callerId);
      expect(call.channel, parkedCall.channel);
      expect(call.cid, parkedCall.cid);
      expect(call.destination, parkedCall.destination);
      expect(call.greetingPlayed, parkedCall.greetingPlayed);
      expect(call.inbound, parkedCall.inbound);
      //expect(call.locked, parkedCall.locked);
      expect(call.rid, parkedCall.rid);
      expect(parkedCall.state, equals(model.CallState.parked));

      return parkedCall;
    }

    if (waitForEvent) {
      final parkEvent = await waitForPark(call.id);

      validateCall(parkEvent.call);

      return parkEvent.call;
    }
    return parkAction;
  }

  /**
   * Returns a Future that completes when an inbound call is
   * received on _the phone_.
   */
  Future<Phonio.Call> waitForInboundCall() {
    log.finest('Receptionist $this waits for inbound call');

    bool match(Phonio.Event event) => event is Phonio.CallIncoming;

    if (this.currentCall != null) {
      log.finest('$this already has call, returning it.');

      return new Future(() => this.currentCall);
    }

    log.finest('$this waits for incoming call from event stream.');
    return this.phone.eventStream.firstWhere(match).then((_) {
      log.finest('$this got expected event, returning current call.');

      return this.currentCall;
    }).timeout(new Duration(seconds: 10));
  }

  /// Perform a call-state reload and await the corresponding event.
  Future callStateReload() async {
    log.info('Performing call-state reload');
    await callFlowControl.stateReload();
    await _waitFor(type: new event.CallStateReload().runtimeType);
  }

  /**
   * Returns a Future that completes when the phone associated with the
   * receptionist is hung up.
   */
  Future waitForPhoneHangup() {
    log.finest('Receptionist $this waits for call hangup');

    if (this.currentCall == null) {
      log.finest('$this already has no call, returning.');
      return new Future(() => null);
    }

    log.finest('$this waits for call hangup from event stream.');
    return this
        .phone
        .eventStream
        .firstWhere((Phonio.Event event) => event is Phonio.CallDisconnected)
        .then((_) {
      log.finest('$this got expected event, returning current call.');
      return null;
    }).timeout(new Duration(seconds: 10));
  }

  /// Returns a Future that completes when the hangup event of [callId]
  /// occurs.
  Future<event.CallHangup> waitForHangup(String callId) async {
    log.finest('$this waits for call $callId to hangup');

    return _waitFor(
        type: new event.CallHangup(model.Call.noCall).runtimeType,
        callID: callId);
  }

  /// Returns a Future that completes when [callId] is parked.
  Future<event.CallPark> waitForPark(String callId) async {
    log.finest('$this waits for call $callId to park');

    return _waitFor(
        type: new event.CallPark(model.Call.noCall).runtimeType,
        callID: callId);
  }

  /// Returns a Future that completes when [callId] is parked.
  Future<event.CallUnpark> waitForUnpark(String callId) async {
    log.finest('$this waits for call $callId to park');

    return _waitFor(
        type: new event.CallUnpark(model.Call.noCall).runtimeType,
        callID: callId);
  }

  /// Returns a Future that completes when [callId] is parked.
  Future<event.CallLock> waitForLock(String callId) async {
    log.finest('$this waits for call $callId to park');

    return _waitFor(
        type: new event.CallLock(model.Call.noCall).runtimeType,
        callID: callId);
  }

  /// Returns a Future that completes when [callId] is parked.
  Future<event.CallUnlock> waitForUnlock(String callId) async {
    log.finest('$this waits for call $callId to park');

    return _waitFor(
        type: new event.CallUnlock(model.Call.noCall).runtimeType,
        callID: callId);
  }

  /// Returns a Future that completes when [callId] is picked up.
  Future<event.CallPickup> waitForPickup(String callId) async {
    log.finest('$this waits for call $callId to be picked up');

    return _waitFor(
        type: new event.CallPickup(model.Call.noCall).runtimeType,
        callID: callId);
  }

  /// Returns a Future that completes when [callId] is enqueued.
  Future<event.QueueLeave> waitForQueueLeave(String callId) async {
    log.finest('$this waits for call $callId to leave queue');

    return _waitFor(
            type: new event.QueueLeave(model.Call.noCall).runtimeType,
            callID: callId)
        .timeout(new Duration(seconds: 10));
  }

  /// Returns a Future that completes when [callId] leaves a queue.
  Future<event.QueueJoin> waitForQueueJoin(String callId) async {
    log.finest('$this waits for call $callId to join queue');

    return await _waitFor(
            type: new event.QueueJoin(model.Call.noCall).runtimeType,
            callID: callId)
        .timeout(new Duration(seconds: 10));
  }

  /// Returns a Future that completes when [callId] is transferred.
  Future<event.CallTransfer> waitForTransfer(String callId) async {
    log.finest('$this waits for call $callId to join queue');

    return await _waitFor(
            type: new event.CallTransfer(model.Call.noCall).runtimeType,
            callID: callId)
        .timeout(new Duration(seconds: 10));
  }

  /// Returns a Future that completes a peer event occurs on [peerId]
  Future<event.PeerState> waitForPeerState(String peerId) async {
    log.finest('$this waits for peer $peerId to change state');

    return await _waitFor(type: new event.PeerState(null).runtimeType)
        .timeout(new Duration(seconds: 10));
  }

  /**
   * Hangs up phone of receptionist directly from the phone.
   */
  Future phoneHangupAll() async {
    log.finest('$this hangs up phone');

    if (this.currentCall == null) {
      log.finest('$this already has no call, returning.');
      return;
    }

    await this.phone.hangupAll();
  }

  /**
   * Originates a new call to [extension] via the [CallFlowControl] service.
   */
  Future<model.Call> originate(
          String extension, model.OriginationContext context) =>
      callFlowControl.originate(extension, context);

  /**
   * Hangup [call]  via the [CallFlowControl] service.
   */
  Future hangUp(model.Call call) =>
      this.callFlowControl.hangup(call.id).catchError((error, stackTrace) {
        log.severe(
            'Tried to hang up call with info ${call.toJson()}. Receptionist info ${toJson()}',
            error,
            stackTrace);
      });

  /**
   * Hangup all active calls currently connected to the phone.
   */
  Future hangupAll() => this.phone.hangup();

  /**
   * Waits for an arbitrary event identified either by [eventType], [callID],
   * [extension], [receptionID], or a combination of them. The method will
   * wait for, at most, [timeoutSeconds] before returning a Future error.
   */
  Future<event.Event> _waitFor(
      {Type type: null,
      String callID: null,
      String extension: null,
      int receptionID: null,
      int timeoutSeconds: 10}) {
    if (type == null &&
        callID == null &&
        extension == null &&
        receptionID == null) {
      return new Future.error(
          new ArgumentError('Specify at least one parameter to wait for'));
    }

    bool matches(event.Event e) {
      bool result = false;
      if (type != null) {
        result = e.runtimeType == type;
      }

      if (callID != null && e is event.CallEvent) {
        result = result && e.call.id == callID;
      }

      if (extension != null && e is event.CallEvent) {
        result = result && e.call.destination == extension;
      }

      if (receptionID != null && e is event.CallEvent) {
        result = result && e.call.rid == receptionID;
      }
      return result;
    }

    event.Event lookup =
        (this.eventStack.firstWhere(matches, orElse: () => null));

    if (lookup != null) {
      return new Future(() => lookup);
    }
    log.finest(
        'Event is not yet received, waiting for maximum $timeoutSeconds seconds');

    return notificationSocket.onEvent
        .firstWhere(matches)
        .timeout(new Duration(seconds: timeoutSeconds))
        .catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      log.severe('Parameters: type:$type, '
          'callID:$callID, '
          'extension:$extension, '
          'receptionID:$receptionID');
      this.dumpEventStack();
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Perform a call pickup via the [CallFlowControl] service. May optionally
   * set [waitForEvent] that will make this method wait until the notification
   * socket confirms the the call was picked up.
   * This method picks up a specific call.
   */
  Future<model.Call> pickup(model.Call call, {waitForEvent: false}) async {
    final pickedUpCall = await callFlowControl.pickup(call.id);

    if (waitForEvent) {
      return (await waitForPickup(call.id)).call;
    }

    return pickedUpCall;
  }

  /**
   * Hunts down the next available call, regardless of lockstate. The Future
   * returned will complete only after the call has been confirmed connected
   * via the notification socket (a call_pickup event is received).
   */
  Future<model.Call> huntNextCall() async {
    Future<model.Call> pickupAfterCallUnlock(model.Call call) async {
      log.info('Call not aquired. $this expects the call to be locked.');

      await waitForLock(call.id);

      log.info('Call $call was locked, waiting for unlock.');
      await waitForUnlock(call.id);

      return pickup(call, waitForEvent: true);
    }

    log.info('$this goes hunting for a call.');

    final model.Call selectedCall = (await waitForCallOffer()).call;

    log.fine('$this attempts to pickup $selectedCall.');

    try {
      return pickup(selectedCall, waitForEvent: true);
    }
// Call is locked.
    on Conflict {
      return pickupAfterCallUnlock(selectedCall);
    }
// Call is hungup
    on NotFound {
      callEventsOnSelectedCall(event.Event e) {
        if (e is event.CallEvent) return e.call.id == selectedCall.id;
      }

      log.info('$this waits for $selectedCall to hangup');

      try {
        await waitForHangup(selectedCall.id);

        // Clear out the events from selected call.
        eventStack.removeWhere(callEventsOnSelectedCall);

        // Reschedule the hunting.
        return this.huntNextCall();
      } on TimeoutException {
        this.dumpEventStack();
        throw new StateError(
            'Expected call to hung up, but no hangup event was received.');
      }
    } catch (error, stackTrace) {
      log.severe('huntNextCall experienced an unexpected error.');
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    }
  }

  /**
   * Convenience function for waiting for the next call being offered to the
   * receptionist.
   */
  Future<event.CallOffer> waitForCallOffer() async {
    log.finest('$this waits for next call offer');

    return _waitFor(type: new event.CallOffer(model.Call.noCall).runtimeType);
  }

  /**
   * Event handler for events coming from the notification server.
   * Merely pushes events onto a stack.
   */
  void _handleEvent(event.Event event) {
    // Only push actual events to the event stack.
    if (event == null) {
      log.warning('Null event received!');
      return;
    }

    eventStack.add(event);
  }

  /**
   * Debug-friendly representation of the receptionist.
   */
  @override
  String toString() => 'Receptionist:${this.user.name}, uid:${this.user.id}, '
      'Phone:${this.phone}';

  /**
   * Event handler for events coming from the phone. Updates the call state
   * of the receptionist.
   */
  void _onPhoneEvent(Phonio.Event event) {
    if (event is Phonio.CallOutgoing) {
      log.finest('$this received call outgoing event');
      Phonio.Call call = new Phonio.Call(
          event.callId, event.callee, false, phone.defaultAccount.username);
      log.finest('$this sets call to $call');

      this.currentCall = call;
    } else if (event is Phonio.CallIncoming) {
      log.finest('$this received incoming call event');
      Phonio.Call call = new Phonio.Call(
          event.callId, event.callee, false, phone.defaultAccount.username);
      log.finest('$this sets call to $call');
      this.currentCall = call;
    } else if (event is Phonio.CallDisconnected) {
      log.finest('$this received call diconnect event');

      this.currentCall = null;
    } else {
      log.severe('$this got unhandled event ${event.eventName}');
    }
  }

  /**
   * Pause the receptionist.
   */
  Future pause(Service.RESTUserStore userStore) =>
      userStore.userStatePaused(user.id);

  /// Await the next available call.
  Future<model.Call> nextOfferedCall() async => (await waitForCallOffer()).call;
}
