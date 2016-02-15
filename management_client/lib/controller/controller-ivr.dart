part of management_tool.controller;

class Ivr {
  final ORService.RESTIvrStore _ivrStore;

  Ivr(this._ivrStore);

  Future<Iterable<ORModel.IvrMenu>> list() => _ivrStore.list();

  Future<ORModel.IvrMenu> update(ORModel.IvrMenu menu) =>
      _ivrStore.update(menu);

  Future<ORModel.IvrMenu> create(ORModel.IvrMenu menu) =>
      _ivrStore.create(menu);
}
