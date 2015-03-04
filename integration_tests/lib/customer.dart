part of or_test_fw;

class Customer {

  static final Logger log = new Logger('Customer');

  Phonio.Call currentCall = null;

  /// The amout of time the actor will wait before answering an incoming call.
  Duration    answerLatency = new Duration(seconds: 0);

  Phonio.SIPPhone _phone = null;
  String get name => this._phone.defaultAccount.username;

  Customer (this._phone) {
    this._phone.eventStream.listen(this._onPhoneEvent);

  }

  Future autoAnswer(bool enabled) =>
    this._phone.autoAnswer(enabled);


  /**
   * Dials an extension and returns a future with a call object.
   */
  Future<Phonio.Call> dial(String extension) {
    log.finest('$this dials $extension');

    return this._phone.originate(extension);
  }

  Future hangup(Phonio.Call call) =>
    new Future.error(new UnimplementedError());

  Future hangupAll() => this._phone.hangupAll();


  Future<Phonio.Call> waitForOutboundCall () {
    log.finest('$this waits for outbound call');
    //TODO: Assert that the call is not answered.
    if (this.currentCall != null) {
      log.finest('$this already has call, returning.');
      return new Future (() => this.currentCall);
    }

    log.finest('$this waits for incoming call from event stream.');
    return this._phone.eventStream.firstWhere(
        (Phonio.Event event)
          => event is Phonio.CallOutgoing)
          .then((_) {
            log.finest('$this got expected event, returning current call.');
            return this.currentCall;
          }).timeout(new Duration(seconds: 10));

  }

  String toString () => '${this.name} PhoneType:${this._phone.runtimeType}';

  void _onPhoneEvent(Phonio.Event event) {
    if (event is Phonio.CallOutgoing) {
      Phonio.CallOutgoing event1 = event;
      Phonio.Call call = new Phonio.Call(event.callID, event.callee, false);
      log.finest('$this sets call to $call');

      this.currentCall = call;
    }

    else if (event is Phonio.CallIncoming) {
      this._handleIncomingCall();
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
          () => this._phone.answerCall())
      .catchError((error, stackTrace) => log.severe(error, stackTrace));
    }
  }
}

