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
  Queue<Model.Event> eventStack = new Queue<Model.Event>();

  Phonio.Call currentCall = null;

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
    .then((_) => this.notificationSocket.eventStream.listen(this._handleEvent))
    .then((_) => this._phone.initialize())
    .then((_) => this._phone.eventStream.listen(this._onPhoneEvent))
    .then((_) => this._phone.autoAnswer(true))
    .then((_) => this._phone.register())
    .then((_) => this.callFlowControl.userStateIdle(this.user.ID))
    .whenComplete((this.readyCompleter.complete));
  }

  /**
   * Perform object teardown.
   * Return a future that completes when the teardown process is done.
   * After teardown is completed, the object may be initialized again.
   */
  Future teardown() {
    if (this._transport != null) {
      this._transport.client.close(force : true);
    }

    this.eventStack.clear();
    this.currentCall = null;

    Future notificationSocketTeardown =
        this.notificationSocket == null
        ? new Future.value()
        : this.notificationSocket.close();

    this.callFlowControl= null;
    Future phoneTeardown = this._phone.teardown();

    return Future.wait([notificationSocketTeardown,
                        phoneTeardown]);
  }

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
   * [CallFlowControl] service.
   */
  Future park(Model.Call call) => this.callFlowControl.park(call.ID);

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
  Future hangUp(Model.Call call) => this.callFlowControl.hangup(call.ID);

  /**
   * Hangup all active calls currently connected to the phone.
   */
  Future hangupAll() => this._phone.hangup();

  /**
   * Waits for an arbitrary event identified either by [eventType], [callID],
   * [extension], [receptionID], or a combination of them. The method will
   * wait for, at most, [timeoutSeconds] before returning a Future error.
   */
  Future<Model.Event> waitFor({String eventType: null, String callID: null,
                               String extension: null, int receptionID: null,
                               int timeoutSeconds: 10}) {
    if (eventType == null && callID == null && extension == null &&
        receptionID == null) {
      return new Future.error
          (new ArgumentError('Specify at least one parameter to wait for'));
    }


    bool matches (Model.Event event) {
      bool result = false;
      if (eventType != null) {
        result = event.eventName == eventType;
      }

      if (callID != null && event is Model.CallEvent) {
        result = result && event.call.ID == callID;
      }

      if (extension != null && event is Model.CallEvent) {
        result = result && event.call.destination == extension;
      }

      if (receptionID != null && event is Model.CallEvent) {
        result = result && event.call.receptionID == receptionID;
      }
      return result;
    }

    Model.Event lookup = (this.eventStack.firstWhere(matches,
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
          => this.waitFor(eventType : Model.EventJSONKey.callPickup,
                          callID    : call.ID))
            .then((Model.CallPickup pickupEvent) => pickupEvent.call);
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

      return this.waitFor (eventType: Model.EventJSONKey.callLock,
                           callID: selectedCall.ID,
                           timeoutSeconds: 10)
          .then((_) => log.info('Call $selectedCall was locked, waiting for unlock.'))
          .then((_) => this.waitFor (eventType: Model.EventJSONKey.callUnlock,
                                     callID: selectedCall.ID))
          .then((_) => log.info('Call $selectedCall got unlocked, picking it up'))
          .then((_) => this.pickup(selectedCall,waitForEvent: true));
    }

    log.info('$this goes hunting for a call.');
    return this.waitForCall()
      .then((Model.Call offeredCall) => selectedCall = offeredCall)
      .then((_) => log.info('$this attempts to pickup $selectedCall.'))
      .then((_) =>
        this.pickup(selectedCall,waitForEvent: true)
          .catchError((error, stackTrace) {
            if (error is Storage.NotFound) {
              return pickupAfterCallUnlock ();
            } else {
              log.severe('huntNextCall experienced an unexpected error.');
              return new Future.error(error, stackTrace);
            }
          }));
  }

  /**
   * Convenience function for waiting for the next call being offered to the
   * receptionist.
   */
  Future<Model.Call> waitForCall() =>
    this.waitFor(eventType: Model.EventJSONKey.callOffer)
      .then((Model.CallOffer offered) => offered.call);

  /**
   * Event handler for events coming from the notification server.
   * Merely pushes events onto a stack.
   */
  void _handleEvent(Model.Event event) {
    // Only push actual events to the event stack.
    if (event == null) {
      log.warning ('Null event received!');
      return;
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
      Phonio.Call call = new Phonio.Call(event.callID, event.callee, false);
      log.finest('$this sets call to $call');

      this.currentCall = call;
    }

    else if (event is Phonio.CallIncoming) {
      log.finest('$this received incoming call event');
      Phonio.Call call = new Phonio.Call(event.callID, event.callee, false);
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
}
