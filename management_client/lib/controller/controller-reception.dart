part of orm.controller;

class Reception {
  final service.RESTReceptionStore _service;
  final model.User _appUser;

  Reception(this._service, this._appUser);

  Future<model.ReceptionReference> create(model.Reception r) =>
      _service.create(r, _appUser).catchError(_handleError);

  Future<model.Reception> get(int rid) =>
      _service.get(rid).catchError(_handleError);

  Future remove(int rid) =>
      _service.remove(rid, _appUser).catchError(_handleError);

  Future<model.ReceptionReference> update(model.Reception r) =>
      _service.update(r, _appUser).catchError(_handleError);

  Future<Iterable<model.ReceptionReference>> list() =>
      _service.list().catchError(_handleError);

  Future<String> changelog(int rid) =>
      _service.changelog(rid).catchError(_handleError);
}
