part of management_tool.controller;

class Dialplan {
  final ORService.RESTDialplanStore _dpStore;

  Dialplan(this._dpStore);

  Future<Iterable<ORModel.ReceptionDialplan>> list() => _dpStore.list();

  Future<ORModel.ReceptionDialplan> update(ORModel.ReceptionDialplan rdp) =>
      _dpStore.update(rdp);

  Future<ORModel.ReceptionDialplan> create(ORModel.ReceptionDialplan rdp) =>
      _dpStore.create(rdp);
}
