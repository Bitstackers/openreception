part of controller;

abstract class Call {

  static void dial(model.DiablePhoneNumber number) {

    event.bus.fire(event.originateCallRequest, number);

    protocol.originateCallFromPhoneId(number.contactID, number.receptionID, number.phoneID).then((protocol.Response response) {

      if (response.status == protocol.Response.OK) {
        event.bus.fire(event.originateCallRequestSuccess, null);
      } else {
        event.bus.fire(event.originateCallRequestFailure, null);
      }

    }).catchError((error) {
      event.bus.fire(event.originateCallRequestFailure, null);
    });
  }

  /**
   * Make the service layer perform a pickup request to the call-flow-control server. 
   */
  static void pickupSpecific(model.Call call) {
    
    event.bus.fire(event.pickupCallRequest, call);

    Service.Call.next().then((model.Call call) {
      event.bus.fire(event.pickupCallSuccess, null);
    }).catchError((error) {
      event.bus.fire(event.pickupCallFailure, null);
    });
  }

  static void pickup() {
    
    event.bus.fire(event.pickupNextCallRequest, null);

    Service.Call.next().then((model.Call call) {
      event.bus.fire(event.pickupCallSuccess, null);
    }).catchError((error) {
      event.bus.fire(event.pickupCallFailure, null);
    });
  }
  
  static void hangup(model.Call call) {

    event.bus.fire(event.hangupCallRequest, call);

    protocol.hangupCall(call).then((protocol.Response response) {

      if (response.status == protocol.Response.OK) {
        event.bus.fire(event.hangupCallRequestSuccess, call);
      } else {
        event.bus.fire(event.hangupCallRequestFailure, call);
      }

    }).catchError((error) {
      event.bus.fire(event.hangupCallRequestFailure, call);
    });
  }

  static void park(model.Call call) {

    event.bus.fire(event.parkCallRequest, call);

    protocol.parkCall(call).then((protocol.Response response) {

      if (response.status == protocol.Response.OK) {
        event.bus.fire(event.parkCallRequestSuccess, call);
      } else {
        event.bus.fire(event.parkCallRequestSuccess, call);
      }

    }).catchError((error) {
      event.bus.fire(event.parkCallRequestSuccess, call);
    });
  }

  static dialContact(model.Contact contact, int phoneID) {

    //TODO: Check if the contact's phone list contains the phoneID supplied. Or cast to DialablePhoneNumber later on.
    // Perhaps we should also find a way to store the reception id with the contact.

    //TODO: Put into the event stream that a new call was originated.
  }
}
