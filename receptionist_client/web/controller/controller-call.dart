part of controller;

enum CallCommand {
  PICKUP,
  PICKUPSUCCESS,
  PICKUPFAILURE,
  DIAL,
  DIALSUCCESS,
  DIALFAILURE,
  HANGUP,
  HANGUPSUCCESS,
  HANGUPFAILURE,
  PARK,
  PARKSUCCESS,
  PARKFAILURE,
  TRANSFER,
  TRANSFERSUCCESS,
  TRANSFERFAILURE
}

abstract class Call {
  static final Logger log = new Logger ('${libraryName}.Call');

  static Bus<CallCommand> _command = new Bus<CallCommand>();
  static Stream<CallCommand> get commandStream => _command.stream;

  static Future dial(String extension, Model.Reception reception, Model.Contact contact) {
    log.info('Dialing $extension.');

    _command.fire(CallCommand.DIAL);
//    return Service.Call.instance.originate(contact, reception, extension)
    return _call.originate(contact, reception, extension)
      .then((_) => _command.fire(CallCommand.DIALSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.DIALFAILURE);
      });
  }

  static Future<Model.Call> pickupParked (Model.Call call) => pickup (call);


  /**
   * Make the service layer perform a pickup request to the
   * call-flow-control server.
   */
  static Future<Model.Call> pickup(Model.Call call) {
    log.info('Picking up $call.');

    _command.fire(CallCommand.PICKUP);
//    return Service.Call.instance.pickup(call)
    return _call.pickup(call)
      .then((_) => _command.fire(CallCommand.PICKUPSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.PICKUPFAILURE);
      });
  }

  static Future hangup(Model.Call call) {
    log.info('Hanging up $call.');

    _command.fire(CallCommand.HANGUP);
//    return Service.Call.instance.hangup(call)
    return _call.hangup(call)
      .then((_) => _command.fire(CallCommand.HANGUPSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.HANGUPFAILURE);
      });
  }

  static Future park(Model.Call call) {
    _command.fire(CallCommand.PARK);
//    return Service.Call.instance.park(call)
    return _call.park(call)
      .then((_) => _command.fire(CallCommand.PARKSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.PARKFAILURE);
      });
  }

  static Future transfer(Model.Call source, Model.Call destination) {
    _command.fire(CallCommand.TRANSFER);
//    return Service.Call.instance.transfer(source, destination)
    return _call.transfer(source, destination)
      .then((_) => _command.fire(CallCommand.TRANSFERSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.TRANSFERFAILURE);
      });
    }
}
