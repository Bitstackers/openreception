part of or_test_fw;

class Receptionist {

  static final Logger log = new Logger('Receptionist');

  final Model.User user;
  final Phonio.SIPPhone _phone;
  Service.NotificationSocket notificationSocket;
  Service.CallFlowControl callFlowControl;
  final String authToken;
  Completer readyCompleter = new Completer();
  Transport.Client _transport = null;

  Phonio.Call currentCall = null;
  Queue<Model.Event> eventStack = new Queue<Model.Event>();

  /// The amout of time the actor will wait before answering an incoming call.
  Duration answerLatency = new Duration(seconds: 0);

  Receptionist(this._phone, this.authToken, this.user);

  /**
   *
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
    .then((_) => this._phone.eventStream.listen(this._onPhoneEvent))
    .then((_) => this._phone.initialize())
    .then((_) => this._phone.autoAnswer(true))
    .then((_) => this._phone.register())
    .then((_) => this.callFlowControl.userStateIdle(this.user.ID))
    .whenComplete((this.readyCompleter.complete));
  }

  Future teardown() {
    this._transport.client.close(force : true);
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

  void cleanState() {
    log.finest('Cleaning up $this');
    this._phone.hangupAll();
    this.eventStack.clear();
    this.notificationSocket.close();
  }

  Future shutdown() {
    return this.notificationSocket.close();
  }

  /**
   * Dumps the current event stack of the Receptionist to log stream.
   */
  void dumpEventStack() {
    log.severe('=== $this eventStack contents;');
    log.severe(this.eventStack);
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

  Future transferCall(Model.Call inboundCall,
      Model.Call outboundCall) => this.callFlowControl.transfer(inboundCall.ID, outboundCall.ID);


  Future park(Model.Call call) => this.callFlowControl.park(call.ID);

  /**
   * Returns a Future that completes when an inbound call is
   * received on _the phone_.
   */
  Future<Phonio.Call> waitForInboundCall() {
    log.finest('Receptionist $this waits for inbound call');
    //TODO: Assert that the call is not answered and is acutally inbound.
    if (this.currentCall != null) {
      log.finest('$this already has call, returning it.');
      return new Future(() => this.currentCall);
    }

    log.finest('$this waits for incoming call from event stream.');
    return this._phone.eventStream.firstWhere(
        (Phonio.Event event) => event is Phonio.CallIncoming).then((_) {
      log.finest('$this got expected event, returning current call.');
      return this.currentCall;
    }).timeout(new Duration(seconds: 10));
  }
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

  Future<Model.Call> originate(String extension, int contactID,
      int receptionID) =>
      this.callFlowControl.originate(extension, contactID, receptionID);

  Future hangUp(Model.Call call) => this.callFlowControl.hangup(call.ID);


  Future hangupAll() => this._phone.hangup();

  Future<Model.Event> waitFor({String eventType: null, String callID: null, String extension:
      null, int receptionID: null, int timeoutSeconds: 10}) {
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

    return notificationSocket.eventStream.firstWhere(matches)
        .timeout(new Duration(seconds: timeoutSeconds));
  }

  Future pickup(Model.Call call, {waitForEvent : false}) {
    Future pickupAction = this.callFlowControl.pickup(call.ID);

    if (waitForEvent) {
      return pickupAction.then((_)
          => this.waitFor(eventType : Model.EventJSONKey.callPickup,
                          callID    : call.ID));
    } else {
      return pickupAction;
    }
  }

  Future<Model.Call> waitForCall() => this.waitFor(eventType: 'call_offer')
      .then((Model.CallOffer offered) => offered.call);

  void _handleEvent(Model.Event event) {
    if (event == null) {
      log.warning ('Null event received!');
      return;
    }

    //log.finest(
    //    '$this received event ${event.eventName} from Notification server');
    this.eventStack.add(event);
  }

  @override
  String toString() => 'Receptionist uid:${this.user.ID}, '
                       'peerID:${this._phone.ID} '
                       'PhoneType:${this._phone.runtimeType}';

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
