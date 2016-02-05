part of controller;

enum CallCommand {
  pickup,
  pickupSuccess,
  pickupFailure,
  dial,
  dialSuccess,
  dialFailure,
  hangup,
  hangupSuccess,
  hangupFailure,
  park,
  parkSuccess,
  parkFailure,
  transfer,
  transferSuccess,
  transferFailure
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
   *
   * Setting [contextCallId] creates a reference between the newly created call and the given id.
   */
  Future<ORModel.Call> dial(
      ORModel.PhoneNumber phoneNumber, ORModel.Reception reception, ORModel.Contact contact,
      {String contextCallId: ''}) async {
    _log.info('Dialing ${phoneNumber.endpoint}.');
    final ORModel.OriginationContext context = new ORModel.OriginationContext()
      ..contactId = contact.ID
      ..receptionId = reception.ID
      ..callId = contextCallId
      ..dialplan = reception.dialplan;

    _busy = true;

    _command.fire(CallCommand.dial);

    return await _service.originate(phoneNumber.endpoint, context).then((ORModel.Call call) {
      _command.fire(CallCommand.dialSuccess);

      return call;
    }).catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.dialFailure);

      return new ControllerError(error.toString());
    }).whenComplete(() => _busy = false);
  }

  /**
   * Returns the first parked call.
   */
  Future<ORModel.Call> _firstParkedCall() async {
    final Iterable<ORModel.Call> calls = await _service.callList();

    return await calls.firstWhere(
        (ORModel.Call call) =>
            call.assignedTo == _appState.currentUser.id && call.state == ORModel.CallState.Parked,
        orElse: () => ORModel.Call.noCall);
  }

  /**
   * Returns the [callId] [ORModel.Call].
   *
   * Returns [ORModel.Call.noCall] if [callId] does not exist.
   */
  Future<ORModel.Call> get(String callId) async {
    try {
      return await _service.get(callId);
    } catch (error) {
      return ORModel.Call.noCall;
    }
  }

  /**
   * Tries to hangup [call].
   */
  Future hangup(ORModel.Call call) {
    _busy = true;

    _command.fire(CallCommand.hangup);

    _log.info('Hanging up $call.');

    return _service
        .hangup(call.ID)
        .then((_) => _command.fire(CallCommand.hangupSuccess))
        .catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.hangupFailure);

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
  Future<ORModel.Call> park(ORModel.Call call) async {
    if (call == ORModel.Call.noCall) {
      return ORModel.Call.noCall;
    }

    _busy = true;
    _command.fire(CallCommand.park);

    return await _service.park(call.ID).then((ORModel.Call parkedCall) {
      _command.fire(CallCommand.parkSuccess);

      _log.info('Parking ${parkedCall}');

      return parkedCall;
    }).catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.parkFailure);

      throw new ControllerError(error.toString());
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

    _command.fire(CallCommand.pickup);

    _log.info('Picking up $call.');

    return await _service.pickup(call.ID).then((ORModel.Call call) {
      _command.fire(CallCommand.pickupSuccess);

      return call;
    }).catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.pickupFailure);

      throw new ControllerError(error.toString());
    }).whenComplete(() => _busy = false);
  }

  /**
   * Tries to pickup the first parked call and returns it if successful.
   */
  Future<ORModel.Call> pickupFirstParkedCall() =>
      _firstParkedCall().then((ORModel.Call parkedCall) =>
          parkedCall != null ? pickup(parkedCall) : ORModel.Call.noCall) as Future<ORModel.Call>;

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
      return await pickup(foundCall);
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
  Future _transfer(ORModel.Call source, ORModel.Call destination) async {
    _busy = true;
    _command.fire(CallCommand.transfer);

    return await _service
        .transfer(source.ID, destination.ID)
        .then((_) => _command.fire(CallCommand.transferSuccess))
        .catchError((error, stackTrace) {
      _log.severe(error, stackTrace);
      _command.fire(CallCommand.transferFailure);

      return new ControllerError(error.toString());
    }).whenComplete(() => _busy = false);
  }

  /**
   * Tries to transfer [source] to [destination].
   */
  Future transfer(ORModel.Call source, ORModel.Call destination) {
    return _transfer(source, destination);
  }

  /**
   * Tries to transfer [source] to the first parked call.
   */
  Future transferToFirstParkedCall(ORModel.Call source) {
    return _firstParkedCall().then((ORModel.Call parkedCall) {
      if (parkedCall != null) {
        return _transfer(source, parkedCall);
      }

      return null;
    });
  }
}
