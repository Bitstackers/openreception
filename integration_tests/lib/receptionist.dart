part of or_test_fw;

class Receptionist {

  static final Logger log = new Logger ('Receptionist');

  final Phonio.SIPPhone             _phone;
  final Service.NotificationSocket  notificationSocket;
  final Service.CallFlowControl     callFlowControl;
  final String                      authToken;
  Queue<Model.Event>          eventStack         = new Queue();

  Receptionist (this._phone, this.notificationSocket, this.callFlowControl, this.authToken) {
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

  Future pickup(Model.Call call) => this.waitFor(eventType: 'call_offer');

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

