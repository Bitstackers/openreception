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

class BusyException implements Exception {

  final String message;
  const BusyException([this.message = ""]);

  String toString() => "BusyException: $message";
}

class Call {
  final Model.AppClientState      _appState;
  final Bus<CallCommand>          _command = new Bus<CallCommand>();
  static final Logger             _log = new Logger ('${libraryName}.Call');
  final ORService.CallFlowControl _service;
  bool _busyFlag = false;

  set _busy (bool makeBusy) {
    if (_busyFlag && makeBusy) {
      throw new BusyException('CallController busy');
    }

    _busyFlag = makeBusy;
  }

  get busy => _busyFlag;

  /**
   * Constructor.
   */
  Call(ORService.CallFlowControl this._service, Model.AppClientState this._appState);

  /**
   *
   */
  Stream<CallCommand> get commandStream => _command.stream;

  /**
   *
   */
  Future dial(ORModel.PhoneNumber phoneNumber,
                  ORModel.Reception reception, ORModel.Contact contact)  async{
     _log.info('Dialing ${phoneNumber.value}.');

     _busy = true;

     _command.fire(CallCommand.DIAL);

    return _service.originate(phoneNumber.value, contact.ID, reception.ID)
      .then((ORModel.Call call) {
        _command.fire(CallCommand.DIALSUCCESS);
        _appState.activeCall = call;

        return _appState.activeCall;
      })
      .catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        _command.fire(CallCommand.DIALFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      }).whenComplete(() => _busy = false);
  }

  /**
   *
   */
  Future<ORModel.Call> _firstParkedCall() =>
    _service.callList().then((Iterable<ORModel.Call> calls) {
      ORModel.Call parkedCall = calls.firstWhere((ORModel.Call call) =>
        call.assignedTo == _appState.currentUser.ID &&
        call.state == ORModel.CallState.Parked, orElse: () => null);

      if (parkedCall != null) {
        return parkedCall;
      }
      else {
        return ORModel.Call.noCall;
      }
   });

  /**
   *
   */
  Future hangup(ORModel.Call call) {
    _busy = true;

    _command.fire(CallCommand.HANGUP);

    _log.info('Hanging up $call.');

    return _service.hangup(call.ID)
      .then((_) => _command.fire(CallCommand.HANGUPSUCCESS))
      .catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        _command.fire(CallCommand.HANGUPFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      }).whenComplete(() => _busy = false);
  }

  /**
   *
   */
  Future<Iterable<ORModel.Call>> listCalls() => _service.callList();

  /**
   *
   */
  Future park(ORModel.Call call) {
    if (call == ORModel.Call.noCall) {
      return new Future.value(ORModel.Call.noCall);
    }

    _busy = true;
    _command.fire(CallCommand.PARK);

    return _service.park(call.ID)
      .then((ORModel.Call parkedCall) {
        _command.fire(CallCommand.PARKSUCCESS);

        _appState.activeCall = ORModel.Call.noCall;
        return parkedCall;
      })
      .catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        _command.fire(CallCommand.PARKFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      }).whenComplete(() => _busy = false);
  }

  /**
   * Fetches a list of peers.
   */
  Future<Iterable<ORModel.Peer>> peerList() =>
    _service.peerListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new ORModel.Peer.fromMap(map)));

  /**
   * Make the service layer perform a pickup request to the
   * call-flow-control server.
   */
  Future<ORModel.Call> pickup(ORModel.Call call, {bool inTransaction: false}) async {
    if(!inTransaction) {
      _busy = true;
    }

    _command.fire(CallCommand.PICKUP);

    _log.info('Picking up $call.');

    return _service.pickup(call.ID)
      .then((ORModel.Call call) {
        _command.fire(CallCommand.PICKUPSUCCESS);
        _appState.activeCall = call;

        return _appState.activeCall;
      })
      .catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        _command.fire(CallCommand.PICKUPFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      }).whenComplete(() => _busy = false);
  }

  /**
   *
   */
  Future<ORModel.Call> pickupFirstParkedCall() {
    _busy = true;
    return _firstParkedCall().then((ORModel.Call parkedCall) {

      if (parkedCall != null) {
        return pickup(parkedCall, inTransaction: true);
      }
    }).whenComplete(() => _busy = false);
  }

  /**
   *
   */
  Future<ORModel.Call> pickupNext() async {
    _busy = true;
    bool availableForPickup (ORModel.Call call) =>
      call.assignedTo == ORModel.User.noID && !call.locked;

    Iterable<ORModel.Call> calls = await _service.callList();
      ORModel.Call foundCall = calls.firstWhere
        (availableForPickup, orElse: () => null);

      _busy = false;

      if (foundCall != null) {
        return pickup(foundCall);
      }
      else {
        return ORModel.Call.noCall;
      }
  }

  /**
   *
   */
  Future<ORModel.Call> pickupParked (ORModel.Call call) => pickup (call);

  /**
   *
   */
  Future _transfer(ORModel.Call source, ORModel.Call destination) {
    _busy = true;
    _command.fire(CallCommand.TRANSFER);

    return _service.transfer(source.ID, destination.ID)
      .then((_) => _command.fire(CallCommand.TRANSFERSUCCESS))
      .catchError((error, stackTrace) {
        _log.severe(error, stackTrace);
        _command.fire(CallCommand.TRANSFERFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      }).whenComplete(() => _busy = false);
  }

  /**
   *
   */
  Future transferToFirstParkedCall(ORModel.Call source) {
    _busy = true;
    return _firstParkedCall().then((ORModel.Call parkedCall) {

      if (parkedCall != null) {
        return _transfer(source, parkedCall)
          .then((_) {
            _appState.activeCall = ORModel.Call.noCall;
        });
      }

      return null;
    }).whenComplete(() => _busy = false);
  }
}
