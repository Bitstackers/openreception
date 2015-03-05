part of or_test_fw;

class Receptionist {

  static final Logger log = new Logger('Receptionist');

  final int userID;
  final Phonio.SIPPhone _phone;
  Service.NotificationSocket notificationSocket;
  Service.CallFlowControl callFlowControl;
  final String authToken;

  Phonio.Call currentCall = null;
  Queue<Model.Event> eventStack = new Queue();

  /// The amout of time the actor will wait before answering an incoming call.
  Duration answerLatency = new Duration(seconds: 0);

  Receptionist(this._phone, this.authToken, this.userID) {
    this.callFlowControl = new Service.CallFlowControl(
        Config.CallFlowControlUri,
        this.authToken,
        new Transport.Client());

    Transport.WebSocketClient wsc = new Transport.WebSocketClient();

    this.notificationSocket = new Service.NotificationSocket(wsc);
    wsc.connect(
        Uri.parse('${Config.NotificationSocketUri}?token=${this.authToken}'));

    this.notificationSocket.eventStream.listen(this._handleEvent);
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
   * Globally enable autoanswer on phone.
   */
  Future autoAnswer(bool enabled) => this._phone.autoAnswer(enabled);

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
   * Returns a Future that completes when an inbound call is
   * received on _the phone_.
   */
  Future<Phonio.Call> waitForInboundCall() {
    log.finest('$this waits for inbound call');
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

  Future<Model.Call> originate(String extension, int contactID,
      int receptionID) =>
      this.callFlowControl.originate(extension, contactID, receptionID);

  Future hangUp(Model.Call call) => this.callFlowControl.hangup(call.ID);


  Future hangupAll() => this._phone.hangup();

  Future waitFor({String eventType: null, String callID: null, String extension:
      null, int receptionID: null, int timeoutSeconds: 10}) {


    Model.Event lookup = (this.eventStack.firstWhere(
        (Model.Event event) => event.eventName == eventType,
        orElse: () => null));

    if (lookup != null) {
      return new Future(() => lookup);
    }

    return notificationSocket.eventStream.firstWhere(
        (Model.Event event) =>
            event != null &&
                event.eventName == eventType).timeout(new Duration(seconds: timeoutSeconds));
  }

  Future pickup(Model.Call call) => this.callFlowControl.pickup(call.ID);

  Future waitForCall() => this.waitFor(eventType: 'call_offer');

  void _handleEvent(Model.Event event) {
    if (event == null) {
      log.severe('Null event received!');
      return;
    }

    log.finest(
        '$this received event ${event.eventName} from Notification server');
    this.eventStack.add(event);
  }

  @override
  String toString() => '${this.userID}  PhoneType:${this._phone.runtimeType}';

}
