part of management_tool.controller;

class Ivr {
  final ORService.RESTIvrStore _ivrStore;
  final ORService.RESTDialplanStore _dpStore;

  Ivr(this._ivrStore, this._dpStore);

  Future<Iterable<ORModel.IvrMenu>> list() => _ivrStore.list();
  Future<Iterable<ORModel.ReceptionDialplan>> listUsage(
          String menuName) async =>
      (await _dpStore.list()).where((ORModel.ReceptionDialplan rdp) =>
          rdp.allActions.any((action) =>
              action is ORModel.Ivr && action.menuName == menuName));

  Future<ORModel.IvrMenu> update(ORModel.IvrMenu menu) =>
      _ivrStore.update(menu);

  Future<ORModel.IvrMenu> create(ORModel.IvrMenu menu) =>
      _ivrStore.create(menu);

  Future<ORModel.IvrMenu> get(String menuName) => _ivrStore.get(menuName);

  Future remove(String menuName) => _ivrStore.remove(menuName);
}
