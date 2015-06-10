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

class Call {
  static final Logger log = new Logger ('${libraryName}.Call');

  Bus<CallCommand> _command = new Bus<CallCommand>();
  Stream<CallCommand> get commandStream => _command.stream;

  final ORService.CallFlowControl _service;

  Call(this._service);

  Future dial(ORModel.PhoneNumber phoneNumber, ORModel.Reception reception, ORModel.Contact contact) {
    log.info('Dialing ${phoneNumber.value}.');

    _command.fire(CallCommand.DIAL);
    return _service.originate(phoneNumber.value, contact.ID, reception.ID)
      .then((ORModel.Call call) {
        _command.fire(CallCommand.DIALSUCCESS);
        ORModel.Call.activeCall = call;

        return ORModel.Call.activeCall;
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.DIALFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
  }

  Future<ORModel.Call> pickupParked (ORModel.Call call) => pickup (call);

  /**
   * Make the service layer perform a pickup request to the
   * call-flow-control server.
   */
  Future<ORModel.Call> pickup(ORModel.Call call) {
    log.info('Picking up $call.');

    _command.fire(CallCommand.PICKUP);
    return _service.pickup(call.ID)
      .then((ORModel.Call call) {
        _command.fire(CallCommand.PICKUPSUCCESS);
        ORModel.Call.activeCall = call;

        return ORModel.Call.activeCall;
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.PICKUPFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
  }

  /**
   *
   */
  Future<ORModel.Call> pickupNext() {

    bool availableForPickup (ORModel.Call call) =>
      call.assignedTo == ORModel.User.noID && !call.locked;

    return _service.callList().then((Iterable<ORModel.Call> calls) {
      ORModel.Call foundCall = calls.firstWhere
        (availableForPickup, orElse: () => null);

      if (foundCall != null) {
        return pickup(foundCall);
      }
      else {
        return ORModel.Call.noCall;
      }
    });
  }

  /**
   *
   */
  Future<ORModel.Call> pickupFirstParkedCall() {
    return _firstParkedCall().then((ORModel.Call parkedCall) {

      if (parkedCall != null) {
        this.pickup(parkedCall);
      }
    });
  }

  Future hangup(ORModel.Call call) {
    log.info('Hanging up $call.');

    _command.fire(CallCommand.HANGUP);
    return _service.hangup(call.ID)
      .then((_) => _command.fire(CallCommand.HANGUPSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.HANGUPFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
  }

  Future park(ORModel.Call call) {
    if (call == ORModel.Call.noCall) {
      return new Future.value(ORModel.Call.noCall);
    }

    _command.fire(CallCommand.PARK);

    return _service.park(call.ID)
      .then((ORModel.Call parkedCall) {
        _command.fire(CallCommand.PARKSUCCESS);

        ORModel.Call.activeCall = ORModel.Call.noCall;
        return parkedCall;
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.PARKFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
  }

  Future<ORModel.Call> _firstParkedCall() =>
    _service.callList().then((Iterable<ORModel.Call> calls) {
    ORModel.Call parkedCall = calls.firstWhere((ORModel.Call call) =>
      call.assignedTo == ORModel.User.currentUser.ID &&
      call.state == ORModel.CallState.Parked, orElse: () => null);

    if (parkedCall != null) {
      return parkedCall;
    }
    else {
      return ORModel.Call.noCall;
    }
   });


  Future transferToFirstParkedCall(ORModel.Call source) {
    return _firstParkedCall().then((ORModel.Call parkedCall) {

      if (parkedCall != null) {
        return _transfer(source, parkedCall)
          .then((_) {
            ORModel.Call.activeCall = ORModel.Call.noCall;
        });
      }

      return null;
    });
  }

  Future _transfer(ORModel.Call source, ORModel.Call destination) {
    _command.fire(CallCommand.TRANSFER);

    return _service.transfer(source.ID, destination.ID)
      .then((_) => _command.fire(CallCommand.TRANSFERSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.TRANSFERFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
    }

  Future<Iterable<ORModel.Call>> listCalls() => _service.callList();

  /**
   * Fetches a list of peers.
   */
  Future<Iterable<ORModel.Peer>> peerList() =>
    _service.peerListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new ORModel.Peer.fromMap(map)));

}
