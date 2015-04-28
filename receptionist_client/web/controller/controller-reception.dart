part of controller;

class Reception {
  final ORService.RESTReceptionStore _store;

  Reception (this._store);

  Future calendar(Model.Reception reception) =>
    this._store.calendar(reception.ID);

  Future<Iterable<Model.Reception>> list() {
    Completer<Iterable<Model.Reception>> completer =
        new Completer<Iterable<Model.Reception>>();

    this._store.list()
      .then((Iterable<ORModel.ReceptionStub> receptionStubs) {
        List<Model.Reception> receptions = [];

        return Future.forEach(receptionStubs, (ORModel.ReceptionStub stub) =>
          this._store.getMap(stub.ID)
            .then((Map map) {
              receptions.add(new Model.Reception.fromMap(map));
            }))
            .then((_) => completer.complete(receptions))
            .catchError(completer.completeError);
    });

    return completer.future;
  }
}
