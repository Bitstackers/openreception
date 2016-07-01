part of management_tool.controller;

class Dialplan {
  final service.RESTDialplanStore _dpService;
  final service.RESTReceptionStore _rStore;

  Dialplan(this._dpService, this._rStore);

  Future<Iterable<model.ReceptionDialplan>> list() =>
      _dpService.list().catchError(_handleError);

  Future<model.Reception> getByExtensions(String extension) =>
      _rStore.getByExtension(extension).catchError(_handleError);

  Future<model.ReceptionDialplan> get(String extension) =>
      _dpService.get(extension).catchError(_handleError);

  Future<Iterable<String>> deploy(String extension, int rid) =>
      _dpService.deployDialplan(extension, rid).catchError(_handleError);

  Future reloadConfig() => _dpService.reloadConfig().catchError(_handleError);

  Future<model.ReceptionDialplan> update(model.ReceptionDialplan rdp) =>
      _dpService.update(rdp).catchError(_handleError);

  Future<model.ReceptionDialplan> create(model.ReceptionDialplan rdp) =>
      _dpService.create(rdp).catchError(_handleError);

  Future remove(String rdpExtension) =>
      _dpService.remove(rdpExtension).catchError(_handleError);

  Future<String> changelog(String extension) =>
      _dpService.changelog(extension).catchError(_handleError);
}
