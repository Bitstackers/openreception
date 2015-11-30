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

/**
 * Is thrown when a [Call] object is busy talking to the server.
 */
class BusyException implements Exception {
  final String message;

  /**
   * Constructor.
   */
  const BusyException([this.message = ""]);

  String toString() => "BusyException: $message";
}

/**
 * Exposes methods for call operations.
 */
class Call {
  final Model.AppClientState _appState;
  bool _busyFlag = false;
  final Bus<CallCommand> _command = new Bus<CallCommand>();
  static final Logger _log = new Logger('${libraryName}.Call');
  final ORService.CallFlowControl _service;

  /**
   * Constructor.
   */
  Call(ORService.CallFlowControl this._service, Model.AppClientState this._appState);

  /**
   * Return true if the Call object is already busy talking to the server.
   */
  bool get busy => _busyFlag;

  /**
   * Set the [_busyFlag] state. This marks whether the class is busy talking to the server.
   *
   * This throws a [BusyException] if we're already busy.
   */
  set _busy(bool makeBusy) {
    if (_busyFlag && makeBusy) {
      throw new BusyException('CallController busy');
    }

    _busyFlag = makeBusy;
  }

  /**
   * Returns a stream of [CallCommand] enums.
   */
  Stream<CallCommand> get commandStream => _command.stream;

  /**
   * Tries to dial [phoneNumber] in the context of [reception] and [contact].
   */
  Future<ORModel.Call> dial(
      ORModel.PhoneNumber phoneNumber, ORModel.Reception reception, ORModel.Contact contact) async {
    _log.info('Dialing ${phoneNumber.value}.');

    _busy = true;

    _command.fire(CallCommand.DIAL);

    return _service
        .originate(phoneNumber.value, contact.ID, reception.ID)
        .then((ORModel.Call call) {
      _command.fire(CallCommand.DIALSUCCESS);
      _appState.activeCall = call;

      return _appState.activeCall;
    }).catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.DIALFAILURE);

      return new Future.error(new ControllerError(error.toString()));
    }).whenComplete(() => _busy = false);
  }

  /**
   * Returns the first parked call.
   */
  Future<ORModel.Call> _firstParkedCall() =>
      _service.callList().then((Iterable<ORModel.Call> calls) => calls.firstWhere(
          (ORModel.Call call) =>
              call.assignedTo == _appState.currentUser.ID && call.state == ORModel.CallState.Parked,
          orElse: () => ORModel.Call.noCall));

  /**
   * Tries to hangup [call].
   */
  Future hangup(ORModel.Call call) {
    _busy = true;

    _command.fire(CallCommand.HANGUP);

    _log.info('Hanging up $call.');

    return _service
        .hangup(call.ID)
        .then((_) => _command.fire(CallCommand.HANGUPSUCCESS))
        .catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.HANGUPFAILURE);

      return new Future.error(new ControllerError(error.toString()));
    }).whenComplete(() => _busy = false);
  }

  /**
   * Returns a list of current calls.
   */
  Future<Iterable<ORModel.Call>> listCalls() => _service.callList();

  /**
   * Tries to park [call].
   */
  Future<ORModel.Call> park(ORModel.Call call) {
    if (call == ORModel.Call.noCall) {
      return new Future.value(ORModel.Call.noCall);
    }

    _busy = true;
    _command.fire(CallCommand.PARK);

    return _service.park(call.ID).then((ORModel.Call parkedCall) {
      _command.fire(CallCommand.PARKSUCCESS);

      _appState.activeCall = ORModel.Call.noCall;
      return parkedCall;
    }).catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.PARKFAILURE);

      return new Future.error(new ControllerError(error.toString()));
    }).whenComplete(() => _busy = false);
  }

  /**
   * Returns a list of peers.
   */
  Future<Iterable<ORModel.Peer>> peerList() => _service.peerList();

  /**
   * Make the service layer perform a pickup request to the call-flow-control server.
   */
  Future<ORModel.Call> pickup(ORModel.Call call) async {
    _busy = true;

    _command.fire(CallCommand.PICKUP);

    _log.info('Picking up $call.');

    return _service.pickup(call.ID).then((ORModel.Call call) {
      _command.fire(CallCommand.PICKUPSUCCESS);
      _appState.activeCall = call;

      return _appState.activeCall;
    }).catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.PICKUPFAILURE);

      return new Future.error(new ControllerError(error.toString()));
    }).whenComplete(() => _busy = false);
  }

  /**
   * Tries to pickup the first parked call and returns it if successful.
   */
  Future<ORModel.Call> pickupFirstParkedCall() => _firstParkedCall().then(
      (ORModel.Call parkedCall) => parkedCall != null ? pickup(parkedCall) : ORModel.Call.noCall);

  /**
   * Requests the next available call, and returns it if successful.
   */
  Future<ORModel.Call> pickupNext() async {
    _busy = true;
    bool availableForPickup(ORModel.Call call) =>
        call.assignedTo == ORModel.User.noID && !call.locked;

    Iterable<ORModel.Call> calls = await _service.callList();
    ORModel.Call foundCall = calls.firstWhere(availableForPickup, orElse: () => null);

    _busy = false;

    if (foundCall != null) {
      return pickup(foundCall);
    } else {
      return ORModel.Call.noCall;
    }
  }

  /**
   * Tries to pickup [call] and returns it if successful.
   */
  Future<ORModel.Call> pickupParked(ORModel.Call call) => pickup(call);

  /**
   * Tries to transfer the [source] call to [destination].
   */
  Future _transfer(ORModel.Call source, ORModel.Call destination) {
    _busy = true;
    _command.fire(CallCommand.TRANSFER);

    return _service
        .transfer(source.ID, destination.ID)
        .then((_) => _command.fire(CallCommand.TRANSFERSUCCESS))
        .catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.TRANSFERFAILURE);

      return new Future.error(new ControllerError(error.toString()));
    }).whenComplete(() => _busy = false);
  }

  /**
   * Tries to transfer [source] to [destination].
   */
  Future transfer(ORModel.Call source, ORModel.Call destination) {
    return _transfer(source, destination).then((_) {
      _appState.activeCall = ORModel.Call.noCall;
    });
  }

  /**
   * Tries to transfer [source] to the first parked call.
   */
  Future transferToFirstParkedCall(ORModel.Call source) {
    return _firstParkedCall().then((ORModel.Call parkedCall) {
      if (parkedCall != null) {
        return _transfer(source, parkedCall).then((_) {
          _appState.activeCall = ORModel.Call.noCall;
        });
      }

      return null;
    });
  }
}
