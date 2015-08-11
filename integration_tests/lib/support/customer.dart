part of or_test_fw;

/**
 * TODO: Implement event stack here instead of just perform logic based on the
 * current call.
 */
class Customer {

  static final Logger log = new Logger('Customer');

  String get extension => '${this._phone.contact}';

  Phonio.Call currentCall = null;

  /// The amout of time the actor will wait before answering an incoming call.
  Duration    answerLatency = new Duration(seconds: 0);

  Phonio.SIPPhone _phone = null;
  Stream<Phonio.Event> get phoneEvents => _phone.eventStream;
  String get name => this._phone.defaultAccount.username;

  Customer (this._phone);

  Map toJson() => {
    'id' : this.hashCode,
    'current_call' : currentCall,
    'extension' : extension
  };

  @override
  int get hashCode => this._phone.contact.hashCode;

  /**
   *
   */
  Future initialize() => this._phone.initialize()
      .then((_) => this._phone.eventStream.listen(this._onPhoneEvent));

  teardown() => this._phone.teardown()
      .then((_) => this.currentCall = null)
      .catchError((error, stackTrace) {
        log.severe('Potential race condition in teardown of Customer, ignoring as test error, but logging it');
        log.severe(error, stackTrace);
      });


  Future Wait_For_Dialtone() => this.waitForInboundCall();

  Future autoAnswer(bool enabled) =>
    this._phone.autoAnswer(enabled);

  /**
   * Dials an extension and returns a future with a call object.
   */
  Future<Phonio.Call> dial(String extension) {
    log.finest('$this dials $extension');

    return this._phone.originate('$extension@${this._phone.defaultAccount.server}');
  }

  /**
   * TODO Use event Stack instead.
   */
  Future waitForHangup() {
    log.finest('$this waits for current call to vanish.');
    //TODO: Assert that the call is not and is acutally outbound.
    if (this.currentCall == null) {
      log.finest('$this already has no call, returning it.');
      return new Future.value(null);
    }


    log.finest('$this waits for call disconnect from event stream.');
    return this._phone.eventStream.firstWhere(
        (Phonio.Event event)
          => event is Phonio.CallDisconnected)
          .then((_) {
            log.finest('$this got expected event, returning .');
            return new Future.value(null);
          }).timeout(new Duration(seconds: 10));
  }

  pickupCall () => this._phone.answer();

  Future hangup(Phonio.Call call) =>
    new Future.error(new UnimplementedError());

  Future hangupAll() => this._phone.hangupAll();


  /**
   * Returns a Future that completes when an outbound call is confirmed placed.
   */
  Future<Phonio.Call> waitForOutboundCall () {
    log.finest('$this waits for outbound call');
    //TODO: Assert that the call is not answered and is acutally outbound.
    if (this.currentCall != null) {
      log.finest('$this already has call, returning it.');
      return new Future (() => this.currentCall);
    }


    log.finest('$this waits for outgoing call from event stream.');
    return this._phone.eventStream.firstWhere(
        (Phonio.Event event)
          => event is Phonio.CallOutgoing)
          .then((_) {
            log.finest('$this got expected event, returning current call.');
            return this.currentCall;
          }).timeout(new Duration(seconds: 10));

  }

  /**
   * Returns a Future that completes when an inbound call is received.
   */
  Future<Phonio.Call> waitForInboundCall () {
    log.finest('$this waits for inbound call');
    //TODO: Assert that the call is not answered and is acutally inbound.
    if (this.currentCall != null) {
      log.finest('$this already has call, returning it.');
      return new Future.value(this.currentCall);
    }

     log.finest('$this waits for incoming call from event stream.');
    return this._phone.eventStream.firstWhere(
        (Phonio.Event event)
          => event is Phonio.CallIncoming)
          .then((_) {
            log.finest('$this got expected event, returning current call.');
            return this.currentCall;
          }).timeout(new Duration(seconds: 10));

  }

  @override
  String toString() => 'Customer peerID:${this._phone.ID} '
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

      //this._handleIncomingCall();
    }

    else if (event is Phonio.CallDisconnected) {
      log.finest('$this received call diconnect event');
      //this._handleDisconnectedCall();
      this.currentCall = null;
    }

    else {
      log.severe('$this got unhandled event ${event.eventName}');
    }
  }

  void _handleIncomingCall() {
    //TODO: Check if phone autoanswer is enabled and return if so.
    if (this.answerLatency.isNegative) {
      return;
    } else {
      // Schedule a pickup later on.
      new Future.delayed(this.answerLatency,
          () => this._phone.answer())
      .catchError((error, stackTrace) => log.severe(error, stackTrace));
    }
  }

  void _handleDisconnectedCall() {
    log.finest('Clearing current call');
    this.currentCall = null;
  }
}

