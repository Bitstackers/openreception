part of or_test_fw;

class Receptionist {

  static final Logger log = new Logger ('Receptionist');

  final int                         userID;
  final Phonio.SIPPhone             _phone;
        Service.NotificationSocket  notificationSocket;
        Service.CallFlowControl     callFlowControl;
  final String                      authToken;
  Queue<Model.Event>          eventStack         = new Queue();

  Receptionist (this._phone, this.authToken, this.userID) {
    this.callFlowControl = new Service.CallFlowControl
        (Config.CallFlowControlUri,this.authToken, new Transport.Client());

    Transport.WebSocketClient wsc = new Transport.WebSocketClient();

    this.notificationSocket =  new Service.NotificationSocket(wsc);
    wsc.connect(Uri.parse('${Config.NotificationSocketUri}?token=${this.authToken}'));

    this.notificationSocket.eventStream.listen(this._handleEvent);


  }

  Future<Model.Call> originate (String extension, int contactID, int receptionID) =>
      this.callFlowControl.originate (extension, contactID, receptionID);

  Future hangupAll () =>
      this._phone.hangup();

  Future waitFor({String eventType      : null,
                  String callID         : null,
                  String extension      : null,
                  int    receptionID    : null,
                  int    timeoutSeconds : 10}) {


    Model.Event lookup = (this.eventStack.firstWhere(
        (Model.Event event) =>
          event.eventName == eventType,
         orElse : () => null));

    if (lookup != null) {
      return new Future(() => lookup);
    }

    return notificationSocket.eventStream.firstWhere((Model.Event event) =>
        event != null && event.eventName == eventType)
        .timeout(new Duration(seconds: timeoutSeconds));
    }

  Future pickup(Model.Call call) => this.callFlowControl.pickup(call.ID);

  Future waitForCall() => this.waitFor(eventType: 'call_offer');

  void _handleEvent (Model.Event event) {
    if (event == null) {
      log.severe('Null event received!');
      return;
    }

    log.finest ('$this received event ${event.eventName} from Notification server');
    this.eventStack.add(event);
  }

  @override
  String toString () => this._phone.ID.toString();

}

