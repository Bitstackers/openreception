part of management_tool.controller;

class Dialplan {
  final ORService.RESTDialplanStore _dpStore;
  final ORService.RESTReceptionStore _rStore;

  Dialplan(this._dpStore, this._rStore);

  Future<Iterable<ORModel.ReceptionDialplan>> list() => _dpStore.list();

  Future<Iterable<ORModel.Reception>> listUsage(String extension) async =>
      (await _rStore.list())
          .where((ORModel.Reception r) => r.dialplan == extension);

  Future<ORModel.ReceptionDialplan> get(String extension) =>
      _dpStore.get(extension);

  Future<ORModel.ReceptionDialplan> update(ORModel.ReceptionDialplan rdp) =>
      _dpStore.update(rdp);

  Future<ORModel.ReceptionDialplan> create(ORModel.ReceptionDialplan rdp) =>
      _dpStore.create(rdp);

  Future remove(String rdpExtension) => _dpStore.remove(rdpExtension);
}
