part of management_tool.controller;

class Dialplan {
  final service.RESTDialplanStore _dpStore;
  final service.RESTReceptionStore _rStore;

  Dialplan(this._dpStore, this._rStore);

  Future<Iterable<model.ReceptionDialplan>> list() => _dpStore.list();

  Future<model.Reception> getByExtensions(String extension) =>
      _rStore.getByExtension(extension);

  Future<model.ReceptionDialplan> get(String extension) =>
      _dpStore.get(extension);

  Future<Iterable<String>> deploy(String extension, int rid) =>
      _dpStore.deployDialplan(extension, rid);

  Future reloadConfig() => _dpStore.reloadConfig();

  Future<model.ReceptionDialplan> update(model.ReceptionDialplan rdp) =>
      _dpStore.update(rdp);

  Future<model.ReceptionDialplan> create(model.ReceptionDialplan rdp) =>
      _dpStore.create(rdp);

  Future remove(String rdpExtension) => _dpStore.remove(rdpExtension);
}
