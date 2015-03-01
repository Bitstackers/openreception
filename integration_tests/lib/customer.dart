part of or_test_fw;

class Customer {

  static final Logger log = new Logger('Customer');

  Phonio.Call currentCall = null;

  Phonio.SIPPhone _phone = null;
  String get name => this._phone.defaultAccount.username;

  Customer (this._phone) {
    this._phone.eventStream.listen(this._onPhoneEvent);

  }

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

  String toString () => '${this._phone.ID}';

  void _onPhoneEvent(Phonio.Event event) {
    if (event is Phonio.CallOutgoing) {
      Phonio.CallOutgoing event1 = event;
      Phonio.Call call = new Phonio.Call(event.callID, event.callee, false);
      log.finest('$this sets call to $call');

      this.currentCall = call;
    } else {
      log.severe('$this got unhandled event ${event.eventName}');
    }
  }
}

