part of openreception.managementclient.controller;

class Reception {
  final ORService.RESTReceptionStore _service;
  final ORService.RESTReceptionStore _management;

  Reception(this._service, this._management);

  Future<ORModel.Reception> create(ORModel.Reception reception) =>
      _service.create(reception);

  Future<ORModel.Reception> get(int receptionID) => _service.get(receptionID);

  Future remove(int receptionID) => _service.remove(receptionID);

  Future<ORModel.Reception> update(ORModel.Reception reception) =>
      _service.update(reception);

  Future<Iterable<ORModel.Reception>> list() => _service.list();

}
