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

  Future dial(ORModel.PhoneNumber phoneNumber, Model.Reception reception, Model.Contact contact) {
    log.info('Dialing ${phoneNumber.value}.');

    _command.fire(CallCommand.DIAL);
    return this._service.originate(phoneNumber.value, contact.ID, reception.ID)
      .then((ORModel.Call orCall) {
        _command.fire(CallCommand.DIALSUCCESS);
        Model.Call.activeCall = new Model.Call.fromORModel(orCall);

        return Model.Call.activeCall;
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.DIALFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
  }

  Future<Model.Call> pickupParked (Model.Call call) => pickup (call);

  /**
   * Make the service layer perform a pickup request to the
   * call-flow-control server.
   */
  Future<Model.Call> pickup(Model.Call call) {
    log.info('Picking up $call.');

    _command.fire(CallCommand.PICKUP);
    return this._service.pickupMap(call.ID)
      .then((Map callMap) {
        _command.fire(CallCommand.PICKUPSUCCESS);
        Model.Call.activeCall = new Model.Call.fromMap(callMap);

        return Model.Call.activeCall;
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
  Future<Model.Call> pickupNext() {

    bool availableForPickup (ORModel.Call call) =>
      call.assignedTo == Model.User.noID && !call.locked;

    return this._service.callList().then((Iterable<ORModel.Call> calls) {
      ORModel.Call foundCall = calls.firstWhere
        (availableForPickup, orElse: () => null);

      if (foundCall != null) {
        return pickup(new Model.Call.fromORModel(foundCall));
      }
      else {
        return Model.Call.noCall;
      }
    });
  }

  /**
   *
   */
  Future<Model.Call> pickupFirstParkedCall() {
    return _firstParkedCall().then((Model.Call parkedCall) {

      if (parkedCall != null) {
        this.pickup(new Model.Call.fromORModel(parkedCall));
      }
    });
  }

  Future hangup(Model.Call call) {
    log.info('Hanging up $call.');

    _command.fire(CallCommand.HANGUP);
    return this._service.hangup(call.ID)
      .then((_) => _command.fire(CallCommand.HANGUPSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.HANGUPFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
  }

  Future park(Model.Call call) {
    if (call == Model.Call.noCall) {
      return new Future.value(Model.Call.noCall);
    }

    _command.fire(CallCommand.PARK);

    return this._service.park(call.ID)
      .then((String stuff) {
        _command.fire(CallCommand.PARKSUCCESS);

        Model.Call.activeCall = Model.Call.noCall;
        return new Model.Call.fromMap(JSON.decode(stuff));
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.PARKFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
  }

  Future<Model.Call> _firstParkedCall()=>
    this._service.callList().then((Iterable<ORModel.Call> calls) {
    ORModel.Call parkedCall = calls.firstWhere((ORModel.Call call) =>
      call.assignedTo == Model.User.currentUser.ID &&
      call.state == ORModel.CallState.Parked, orElse: () => null);

    return new Model.Call.fromORModel(parkedCall);
   });


  Future transferToFirstParkedCall(Model.Call source) {
    return _firstParkedCall().then((Model.Call parkedCall) {

      if (parkedCall != null) {
        return _transfer(source, parkedCall)
          .then((_) {
            Model.Call.activeCall = Model.Call.noCall;
        });
      }
      else {
        return new Future.value(null);
      }
    });
  }

  Future _transfer(Model.Call source, Model.Call destination) {
    _command.fire(CallCommand.TRANSFER);

    return this._service.transfer(source.ID, destination.ID)
      .then((_) => _command.fire(CallCommand.TRANSFERSUCCESS))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        _command.fire(CallCommand.TRANSFERFAILURE);

        return new Future.error(new ControllerError(error.toString()));
      });
    }

  Future<Iterable<Model.Call>> listCalls() =>
    this._service.callListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new Model.Call.fromMap(map)));

  /**
   * Fetches a list of peers.
   */
  Future<Iterable<Model.Peer>> peerList() =>
    this._service.peerListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new Model.Peer.fromMap(map)));

}
