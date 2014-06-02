part of controller;

abstract class Call {

  static void dial(String extension, int receptionID, [int contactID]) {

    event.bus.fire(event.originateCallRequest, extension);

    Service.Call.originate(contactID, receptionID, extension).then((_) {
      event.bus.fire(event.originateCallRequestSuccess, null);
    }).catchError((error) {
      event.bus.fire(event.originateCallRequestFailure, null);
    });
  }

  static void completeTransfer(model.TransferRequest request, model.Call destination) {
    request.confirm(destination);
  }


  /**
   * Make the service layer perform a pickup request to the call-flow-control server. 
   */
  static void pickupSpecific(model.Call call) {

    event.bus.fire(event.pickupCallRequest, call);

    Service.Call.pickup(call).then((model.Call call) {
      event.bus.fire(event.pickupCallSuccess, null);
    }).catchError((error) {
      event.bus.fire(event.pickupCallFailure, null);
    });
  }

  static void pickupNext() {

    event.bus.fire(event.pickupNextCallRequest, null);

    Service.Call.next().then((model.Call call) {
      event.bus.fire(event.pickupCallSuccess, null);
    }).catchError((error) {
      event.bus.fire(event.pickupCallFailure, null);
    });
  }

  static void hangup(model.Call call) {

    event.bus.fire(event.hangupCallRequest, call);

    Service.Call.hangup(call).then((model.Call call) {
      event.bus.fire(event.hangupCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.hangupCallRequestFailure, call);
    });
  }

  static void park(model.Call call) {

    event.bus.fire(event.parkCallRequest, call);

    Service.Call.park(call).then((model.Call call) {
        event.bus.fire(event.parkCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.parkCallRequestSuccess, call);
    });
  }

  static void transfer(model.Call source, model.Call destination) {

    event.bus.fire(event.transferCallRequest, source);

    Service.Call.transfer(source, destination).then((model.Call call) {
        event.bus.fire(event.transferCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.transferCallRequestSuccess, source);
    });
  }
}
