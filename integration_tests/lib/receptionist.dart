part of or_test_fw;

class Receptionist {

  String authToken = null;
  Phonio.SIPPhone _phone = null;
  Service.NotificationSocket  notificationSocket = null;
  Service.CallFlowControl     callFlowControl    = null;
  Queue<Model.Event>          eventStack         = new Queue();

  Receptionist (this._phone);

  Future<Model.Call> originate (String extension, int contactID, int receptionID) =>
      this.callFlowControl.originate (extension, contactID, receptionID);

  Future hangup (Phonio.Call call) =>
      this._phone.hangup(call);

  Future waitFor({String eventType      : null,
                  String callID         : null,
                  String extension      : null,
                  int    receptionID    : null,
                  int    timeoutSeconds : 10}) {

    return new Future (() => throw new StateError('Not implemented')).timeout(new Duration(seconds: timeoutSeconds));

    }

  Future pickup(Model.Call call) => this.waitFor(eventType: 'call_offer');

  Future waitForCall() => this.waitFor(eventType: 'call_offer');

}

