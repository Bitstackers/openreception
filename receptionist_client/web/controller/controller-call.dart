part of controller;

abstract class Call {
  static final Logger log = new Logger ('${libraryName}.Call');

  static void dialSelectedContact() {
    event.bus.fire(event.dialSelectedContact, null);
  }

  static void completeTransfer(Model.TransferRequest request, Model.Call destination) {
    request.confirm(destination);
  }


  static void pickupParked (Model.Call call) => pickupSpecific(call);

  /**
   * Make the service layer perform a pickup request to the call-flow-control server.
   */
  static void pickupSpecific(Model.Call call) {
    if (call == Model.nullCall) {
      log.info('Discarding request to pickup a null call.');
      return;
    }

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
    if (call == Model.nullCall) {
      log.info('Discarding request to hangup null call.');
      return;
    }

    event.bus.fire(event.hangupCallRequest, call);

    Service.Call.hangup(call).then((Model.Call call) {
      event.bus.fire(event.hangupCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.hangupCallRequestFailure, call);
    });
  }

  static void park(Model.Call call) {
    if (call == Model.nullCall) {
      log.info('Discarding request to park null call.');
      return;
    }

    event.bus.fire(event.parkCallRequest, call);

    Service.Call.park(call).then((Model.Call call) {
        event.bus.fire(event.parkCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.parkCallRequestSuccess, call);
    });
  }

  static void transfer(Model.Call source, Model.Call destination) {
    if ([source, destination].contains(Model.nullCall)) {
      log.info('Discarding request to transfer null call (either source or destination is not valid.');
      return;
    }

    event.bus.fire(event.transferCallRequest, source);

    Service.Call.transfer(source, destination).then((Model.Call call) {
        event.bus.fire(event.transferCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.transferCallRequestSuccess, source);
    });
  }
}
