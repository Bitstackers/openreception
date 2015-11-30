part of or_test_fw;

/**
 * Class modeling the domain actor "Receptionist".
 * Contains references to resources needed in order to make the actor perform
 * the actions described in the use cases.
 * Actions are outlined by public functions such as [pickup].
 */
class Receptionist {

  static final Logger log = new Logger('Receptionist');

  final Model.User user;
  final Phonio.SIPPhone _phone;
  final String authToken;

  Service.NotificationSocket notificationSocket;
  Service.CallFlowControl callFlowControl;
  Transport.Client _transport = null;

  Completer readyCompleter = new Completer();
  Queue<Event.Event> eventStack = new Queue<Event.Event>();

  Phonio.Call currentCall = null;


  Map toJson() => {
    'id' : this.hashCode,
    'user' : user,
    'auth_token' : authToken,
    'phone' : _phone,
    'event_stack' : eventStack.toList()
  };

  int get hashCode => user.ID;

  /// The amout of time the actor will wait before answering an incoming call.
  Duration answerLatency = new Duration(seconds: 0);

  /**
   * Default constructor. Provides an _uninitialized_ [Receptionist] object.
   */
  Receptionist(this._phone, this.authToken, this.user);

  /**
   * Perform object initialization.
   * Return a future that completes when the initialization process is done.
   * This method should only be called by once, and other callers should
   * use the [whenReady] function to wait for the object to become ready.
   */
  Future initialize() {
    this._transport = new Transport.Client();
    this.callFlowControl = new Service.CallFlowControl(
        Config.CallFlowControlUri,
        this.authToken,
        this._transport);

    if (this.readyCompleter.isCompleted) {
      this.readyCompleter = new Completer();
    }

    Transport.WebSocketClient wsc = new Transport.WebSocketClient();
    this.notificationSocket = new Service.NotificationSocket(wsc);

    return wsc.connect(
        Uri.parse('${Config.NotificationSocketUri}?token=${this.authToken}'))
    .then((_) => this.notificationSocket.eventStream.listen(this._handleEvent, onDone : () => log.info('$this closing notification listener.')))
    .then((_) => this._phone.initialize())
    .then((_) => this._phone.eventStream.listen(this._onPhoneEvent, onDone : () => log.info('$this closing event listener.')))
    .then((_) => this._phone.autoAnswer(true))
    .then((_) => this._phone.register())
    .then((_) => this.callFlowControl.userStateIdle(this.user.ID))
    .then((_) => eventStack.clear())
    .then((_) => currentCall = null)
    .whenComplete(this.readyCompleter.complete);
  }

  /**
   * Perform object teardown.
   * Return a future that completes when the teardown process is done.
   * After teardown is completed, the object may be initialized again.
   */
  Future teardown() {
    log.info('Clearing state of $this');
    if (this._transport != null) {
      this._transport.client.close(force : true);
    }
    Future notificationSocketTeardown =
        this.notificationSocket == null
        ? new Future.value()
        : this.notificationSocket.close();

    this.callFlowControl= null;
    Future phoneTeardown = this._phone.teardown();

    return Future.wait([notificationSocketTeardown,
                        phoneTeardown,
                        new Future.delayed(new Duration(milliseconds : 10))])
      .catchError((error, stackTrace) {
        log.severe('Potential race condition in teardown of Receptionist, ignoring as test error, but logging it');
        log.severe(error, stackTrace);
    });
  }

  Future finalize() =>
      _phone.ready
      ? teardown().then((_) => _phone.finalize())
      : _phone.finalize();

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
   * Receptionist state
   */
  String _state = Model.UserState.Unknown;
  void set state (String newState) {
    log.finest('$this changes state from $_state to $newState');
    this._state = newState;
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
  Future autoAnswer(bool enabled) => this._phone.autoAnswer(enabled);

  /**
   * Registers the phone in the PBX SIP registry.
   */
  Future registerAccount() {
    if (this._phone is Phonio.PJSUAProcess) {
      return (this._phone as Phonio.PJSUAProcess).registerAccount();
    } else if (this._phone is Phonio.SNOMPhone) {
      log.severe('Assuming that SNOM phone is already registered.');
      return new Future(() => null);
    } else {
      return new Future.error(
          new UnimplementedError(
              'Unable to register phone type : ' '${this._phone.runtimeType}'));
    }
  }

  /**
   * Transfers active [callA] to active [callB] via the
   * [CallFlowControl] service.
   */
  Future transferCall(Model.Call callA,
      Model.Call callB) =>
          this.callFlowControl.transfer(callA.ID, callB.ID);

  /**
   * Parks [call] in the parking lot associated with the user via the
   * [CallFlowControl] service. May optionally
   * set [waitForEvent] that will make this method wait until the notification
   * socket confirms the the call was sucessfully parked.
   */
  Future park(Model.Call call, {bool waitForEvent : false}) {
    Future parkAction = this.callFlowControl.park(call.ID);

    Model.Call validateCall(Model.Call parkedCall) {
      expect(call.ID, parkedCall.ID);
      expect(call.answeredAt
          .difference(parkedCall.answeredAt).inMilliseconds.abs(),
          lessThan(500));
      expect(call.arrived
          .difference(parkedCall.arrived).inMilliseconds.abs(),
          lessThan(500));
      expect(call.assignedTo, parkedCall.assignedTo);
      expect(call.callerID, parkedCall.callerID);
      expect(call.channel, parkedCall.channel);
      expect(call.contactID, parkedCall.contactID);
      expect(call.destination, parkedCall.destination);
      expect(call.greetingPlayed, parkedCall.greetingPlayed);
      expect(call.inbound, parkedCall.inbound);
      expect(call.locked, parkedCall.locked);
      expect(call.receptionID, parkedCall.receptionID);
      expect(parkedCall.state, equals(Model.CallState.Parked));

      return parkedCall;
    }

    if (waitForEvent) {
      return parkAction.then((_)
          => this.waitFor(eventType : Event.Key.callPark,
                          callID    : call.ID,
                          timeoutSeconds: 2))
            .then((Event.CallPark parkEvent) => validateCall(parkEvent.call));
    } else {
      return parkAction;
    }
  }

  /**
   * Returns a Future that completes when an inbound call is
   * received on _the phone_.
   */
  Future<Phonio.Call> waitForInboundCall() {
    log.finest('Receptionist $this waits for inbound call');

    bool match (Phonio.Event event) => event is Phonio.CallIncoming;

    //TODO: Assert that the call is not answered and is acutally inbound.
    if (this.currentCall != null) {
      log.finest('$this already has call, returning it.');
      return new Future(() => this.currentCall);
    }

    log.finest('$this waits for incoming call from event stream.');
    return this._phone.eventStream.firstWhere(match).then((_) {
      log.finest('$this got expected event, returning current call.');
      return this.currentCall;
    }).timeout(new Duration(seconds: 10));
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
    return this._phone.eventStream.firstWhere(
        (Phonio.Event event) => event is Phonio.CallDisconnected).then((_) {
      log.finest('$this got expected event, returning current call.');
      return null;
    }).timeout(new Duration(seconds: 10));
  }

  /**
   * Originates a new call to [extension] via the [CallFlowControl] service.
   */
  Future<Model.Call> originate(String extension, int contactID,
      int receptionID) =>
      this.callFlowControl.originate(extension, contactID, receptionID);

  /**
   * Hangup [call]  via the [CallFlowControl] service.
   */
  Future hangUp(Model.Call call) =>
    this.callFlowControl.hangup(call.ID)
    .catchError((error, stackTrace) {
    log.severe('Tried to hang up call with info ${call.toJson()}. Receptionist info ${toJson()}', error, stackTrace);

  });

  /**
   * Hangup all active calls currently connected to the phone.
   */
  Future hangupAll() => this._phone.hangup();

  /**
   * Waits for an arbitrary event identified either by [eventType], [callID],
   * [extension], [receptionID], or a combination of them. The method will
   * wait for, at most, [timeoutSeconds] before returning a Future error.
   */
  Future<Event.Event> waitFor({String eventType: null, String callID: null,
                               String extension: null, int receptionID: null,
                               int timeoutSeconds: 10}) {
    if (eventType == null && callID == null && extension == null &&
        receptionID == null) {
      return new Future.error
          (new ArgumentError('Specify at least one parameter to wait for'));
    }


    bool matches (Event.Event event) {
      bool result = false;
      if (eventType != null) {
        result = event.eventName == eventType;
      }

      if (callID != null && event is Event.CallEvent) {
        result = result && event.call.ID == callID;
      }

      if (extension != null && event is Event.CallEvent) {
        result = result && event.call.destination == extension;
      }

      if (receptionID != null && event is Event.CallEvent) {
        result = result && event.call.receptionID == receptionID;
      }
      return result;
    }

    Event.Event lookup = (this.eventStack.firstWhere(matches,
        orElse: () => null));

    if (lookup != null) {
      return new Future(() => lookup);
    }
    log.finest('Event is not yet received, waiting for maximum $timeoutSeconds seconds');

    return notificationSocket.eventStream.firstWhere(matches)
        .timeout(new Duration(seconds: timeoutSeconds))
        .catchError((error, stackTrace) {
          log.severe(error, stackTrace);
          log.severe('Parameters: eventType:$eventType, '
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
  Future pickup(Model.Call call, {waitForEvent : false}) {
    Future pickupAction = this.callFlowControl.pickup(call.ID);

    if (waitForEvent) {
      return pickupAction.then((_)
          => this.waitFor(eventType : Event.Key.callPickup,
                          callID    : call.ID))
            .then((Event.CallPickup pickupEvent) => pickupEvent.call);
    } else {
      return pickupAction;
    }
  }

  /**
   * Hunts down the next available call, regardless of lockstate. The Future
   * returned will complete only after the call has been confirmed connected
   * via the notification socket (a call_pickup event is received).
   */
  Future<Model.Call> huntNextCall() {
    Model.Call selectedCall;

    Future<Model.Call> pickupAfterCallUnlock () {
      log.info('Call not aquired. $this expects the call to be locked.');

      return this.waitFor (eventType: Event.Key.callLock,
                           callID: selectedCall.ID,
                           timeoutSeconds: 10)
          .then((_) => log.info('Call $selectedCall was locked, waiting for unlock.'))
          .then((_) => this.waitFor (eventType: Event.Key.callUnlock,
                                     callID: selectedCall.ID))
          .then((_) => log.info('Call $selectedCall got unlocked, picking it up'))
          .then((_) => this.pickup(selectedCall,waitForEvent: true));
    }

    log.info('$this goes hunting for a call.');
    return this.waitForCall()
      .then((Model.Call offeredCall) => selectedCall = offeredCall)
      .then((_) => log.info('$this attempts to pickup $selectedCall.'))
      .then((_) =>
        this.pickup(selectedCall, waitForEvent: true)
          .then((Model.Call pickedUpCall) {
            log.info('$this got call $pickedUpCall');
            return pickedUpCall;
          })
          .catchError((error, stackTrace) {
            if (error is Storage.Conflict) { // Call is locked.
              return pickupAfterCallUnlock ();
            }
            else if (error is Storage.NotFound) { // Call is hungup

              callEventsOnSelecteCall (Event.Event event) {
                if (event is Event.CallEvent)
                  return event.call.ID == selectedCall.ID;
              }

              log.info('$this waits for $selectedCall to hangup');
              this.waitFor(eventType : Event.Key.callHangup,
                           callID    : selectedCall.ID,
                           timeoutSeconds: 2)
                .then((Event.CallHangup hangupEvent) {
                this.eventStack.removeWhere(callEventsOnSelecteCall);

                // Reschedule the hunting.
                return this.huntNextCall();
              });


              this.dumpEventStack();
              throw new StateError('Expected call to hung up, but no hangup event was received.');

            }
            else {
              log.severe('huntNextCall experienced an unexpected error.');
              log.severe(error, stackTrace);
              return new Future.error(error, stackTrace);
            }
          }));
  }

  /**
   * Convenience function for waiting for the next call being offered to the
   * receptionist.
   */
  Future<Model.Call> waitForCall() =>
    this.waitFor(eventType: Event.Key.callOffer)
      .then((Event.CallOffer offered) => offered.call);

  /**
   * Event handler for events coming from the notification server.
   * Merely pushes events onto a stack.
   */
  void _handleEvent(Event.Event event) {
    // Only push actual events to the event stack.
    if (event == null) {
      log.warning ('Null event received!');
      return;
    }

    if (event is Event.UserState) {
      this.state = event.status.state;
    }

    this.eventStack.add(event);
  }

  /**
   * Debug-friendly representation of the receptionist.
   */
  @override
  String toString() => 'Receptionist:${this.user.name}, uid:${this.user.ID}, '
                       'Phone:${this._phone}';

  /**
   * Event handler for events coming from the phone. Updates the call state
   * of the receptionist.
   */
  void _onPhoneEvent(Phonio.Event event) {
    if (event is Phonio.CallOutgoing) {
      log.finest('$this received call outgoing event');
      Phonio.Call call = new Phonio.Call(event.callID, event.callee, false,
          _phone.defaultAccount.username);
      log.finest('$this sets call to $call');

      this.currentCall = call;
    }

    else if (event is Phonio.CallIncoming) {
      log.finest('$this received incoming call event');
      Phonio.Call call = new Phonio.Call(event.callID, event.callee, false,
          _phone.defaultAccount.username);
      log.finest('$this sets call to $call');
      this.currentCall = call;
    }

    else if (event is Phonio.CallDisconnected) {
      log.finest('$this received call diconnect event');

      this.currentCall = null;
    }

    else {
      log.severe('$this got unhandled event ${event.eventName}');
    }
  }

  /**
   * Sets the userstate to 'paused'.
   */

  Future paused () => this.callFlowControl.userStatePausedMap(this.user.ID);
}
