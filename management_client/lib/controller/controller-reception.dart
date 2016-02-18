part of management_tool.controller;

class Reception {
  final service.RESTReceptionStore _service;

  Reception(this._service);

  Future<model.Reception> create(model.Reception reception) =>
      _service.create(reception);

  Future<model.Reception> get(int receptionID) => _service.get(receptionID);

  Future remove(int receptionID) => _service.remove(receptionID);

  Future<model.Reception> update(model.Reception reception) =>
      _service.update(reception);

  Future<Iterable<model.Reception>> list() => _service.list();
}
