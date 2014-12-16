part of controller;

abstract class Call {

  static const String className = '${libraryName}.Call';

  static void dialSelectedContact() {
    event.bus.fire(event.dialSelectedContact, null);
  }

  static void dial(Model.Extension extension, Model.Reception reception, [Model.Contact contact]) {

    const String context = '${className}.dial';

    if (Model.Call.currentCall.isActive) {
      Model.Call.currentCall.park();
    }

    event.bus.fire(event.originateCallRequest, extension.dialString);

    if (!extension.valid || extension == null) {
      log.errorContext("Trying to dial an invalid extension!", context);
      event.bus.fire(event.originateCallRequestFailure, null);
      return;
    }

    Service.Call.originate((contact == null ? Model.Contact.noContact : contact).id, reception.ID, extension.dialString).then((_) {
      event.bus.fire(event.originateCallRequestSuccess, null);
    }).catchError((error) {
      event.bus.fire(event.originateCallRequestFailure, null);
    });
  }

  static void completeTransfer(Model.TransferRequest request, Model.Call destination) {
    request.confirm(destination);
  }


  /**
   * Make the service layer perform a pickup request to the call-flow-control server.
   */
  static void pickupSpecific(Model.Call call) {

    event.bus.fire(event.pickupCallRequest, call);

    // Verify that the user does not already have a call.
    if (Model.Call.currentCall.isActive) {
      event.bus.fire(event.pickupCallFailure, null);
    }
    else {
      Service.Call.pickup(call).then((Model.Call call) {
        event.bus.fire(event.pickupCallSuccess, null);
      }).catchError((error) {
        event.bus.fire(event.pickupCallFailure, null);
      });
    }
  }

  static void pickupNext() {

    event.bus.fire(event.pickupNextCallRequest, null);

    // Verify that the user does not already have a call.
    if (Model.Call.currentCall.isActive) {
      event.bus.fire(event.pickupCallFailure, null);
    }
    else {
      Service.Call.next().then((Model.Call call) {
        event.bus.fire(event.pickupCallSuccess, null);
      }).catchError((error) {
        event.bus.fire(event.pickupCallFailure, null);
      });
    }
  }

  static void hangup(Model.Call call) {

    event.bus.fire(event.hangupCallRequest, call);

    Service.Call.hangup(call).then((Model.Call call) {
      event.bus.fire(event.hangupCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.hangupCallRequestFailure, call);
    });
  }

  static void park(Model.Call call) {

    event.bus.fire(event.parkCallRequest, call);

    Service.Call.park(call).then((Model.Call call) {
        event.bus.fire(event.parkCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.parkCallRequestSuccess, call);
    });
  }

  static void transfer(Model.Call source, Model.Call destination) {

    event.bus.fire(event.transferCallRequest, source);

    Service.Call.transfer(source, destination).then((Model.Call call) {
        event.bus.fire(event.transferCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.transferCallRequestSuccess, source);
    });
  }
}
