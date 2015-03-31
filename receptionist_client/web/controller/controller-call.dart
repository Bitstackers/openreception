part of controller;

enum CallCommand {
  PICKUP,
  PICKUPSUCCESS,
  PICKUPFAILURE,
  DIAL,
  DIALSUCCESS,
  DIALFAILURE
}

abstract class Call {
  static final Logger log = new Logger ('${libraryName}.Call');

  static Bus<CallCommand> _command = new Bus<CallCommand>();
  static Stream<CallCommand> get commandStream => _command.stream;

  static Future dial(String extension, Model.Reception reception, Model.Contact contact) {
    log.info('Dialing extension.');

    _command.fire(CallCommand.DIAL);
    return Service.Call.originate(contact.ID, reception.ID, extension)
      .then(() => _command.fire(CallCommand.DIALSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.DIALSUCCESS);
      });

  }

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
    if (call == Model.noCall) {
      log.info('Discarding request to pickup a null call.');
      return;
    }

    event.bus.fire(event.pickupCallRequest, call);

    // Verify that the user does not already have a call.
    if (Model.Call.activeCall.isActive) {
      event.bus.fire(event.pickupCallFailure, null);
    }
    else {
      Service.Call.instance.pickup(call).then((Model.Call call) {
        event.bus.fire(event.pickupCallSuccess, null);
      }).catchError((error) {
        event.bus.fire(event.pickupCallFailure, null);
      });
    }
  }

  static void hangup(Model.Call call) {
    if (call == Model.noCall) {
      log.info('Discarding request to hangup null call.');
      return;
    }

    event.bus.fire(event.hangupCallRequest, call);

    Service.Call.instance.hangup(call).then((Model.Call call) {
      event.bus.fire(event.hangupCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.hangupCallRequestFailure, call);
    });
  }

  static void park(Model.Call call) {
    if (call == Model.noCall) {
      log.info('Discarding request to park null call.');
      return;
    }

    event.bus.fire(event.parkCallRequest, call);

    Service.Call.instance.park(call).then((Model.Call call) {
        event.bus.fire(event.parkCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.parkCallRequestSuccess, call);
    });
  }

  static void transfer(Model.Call source, Model.Call destination) {
    if ([source, destination].contains(Model.noCall)) {
      log.info('Discarding request to transfer null call (either source or destination is not valid.');
      return;
    }

    event.bus.fire(event.transferCallRequest, source);

    Service.Call.instance.transfer(source, destination).then((Model.Call call) {
        event.bus.fire(event.transferCallRequestSuccess, call);
    }).catchError((error) {
      event.bus.fire(event.transferCallRequestSuccess, source);
    });
  }
}
