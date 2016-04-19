part of management_tool.controller;

class Dialplan {
  final service.RESTDialplanStore _dpStore;
  final service.RESTReceptionStore _rStore;

  Dialplan(this._dpStore, this._rStore);

  Future<Iterable<model.ReceptionDialplan>> list() =>
      _dpStore.list().catchError(_handleError);

  Future<model.Reception> getByExtensions(String extension) =>
      _rStore.getByExtension(extension).catchError(_handleError);

  Future<model.ReceptionDialplan> get(String extension) =>
      _dpStore.get(extension).catchError(_handleError);

  Future<Iterable<String>> deploy(String extension, int rid) =>
      _dpStore.deployDialplan(extension, rid).catchError(_handleError);

  Future reloadConfig() => _dpStore.reloadConfig().catchError(_handleError);

  Future<model.ReceptionDialplan> update(model.ReceptionDialplan rdp) =>
      _dpStore.update(rdp).catchError(_handleError);

  Future<model.ReceptionDialplan> create(model.ReceptionDialplan rdp) =>
      _dpStore.create(rdp).catchError(_handleError);

  Future remove(String rdpExtension) =>
      _dpStore.remove(rdpExtension).catchError(_handleError);
}
