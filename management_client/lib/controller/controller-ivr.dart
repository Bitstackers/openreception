part of management_tool.controller;

class Ivr {
  final service.RESTIvrStore _ivrStore;
  final service.RESTDialplanStore _dpStore;

  Ivr(this._ivrStore, this._dpStore);

  Future<Iterable<model.IvrMenu>> list() => _ivrStore.list();
  Future<Iterable<model.ReceptionDialplan>> listUsage(String menuName) async =>
      (await _dpStore.list()).where((model.ReceptionDialplan rdp) => rdp
          .allActions
          .any((action) => action is model.Ivr && action.menuName == menuName));

  Future<model.IvrMenu> update(model.IvrMenu menu) => _ivrStore.update(menu);

  Future<model.IvrMenu> create(model.IvrMenu menu) => _ivrStore.create(menu);

  Future<model.IvrMenu> get(String menuName) => _ivrStore.get(menuName);

  Future remove(String menuName) => _ivrStore.remove(menuName);
}
