part of management_tool.controller;

class Reception {
  final service.RESTReceptionStore _service;
  final model.User _appUser;

  Reception(this._service, this._appUser);

  Future<model.ReceptionReference> create(model.Reception r) =>
      _service.create(r, _appUser);

  Future<model.Reception> get(int rid) => _service.get(rid);

  Future remove(int rid) => _service.remove(rid, _appUser);

  Future<model.ReceptionReference> update(model.Reception r) =>
      _service.update(r, _appUser);

  Future<Iterable<model.ReceptionReference>> list() => _service.list();
}
