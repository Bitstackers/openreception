part of management_tool.controller;

class Ivr {
  final service.RESTIvrStore _ivrStore;
  final service.RESTDialplanStore _dpStore;

  Ivr(this._ivrStore, this._dpStore);

  Future<Iterable<model.IvrMenu>> list() =>
      _ivrStore.list().catchError(_handleError);
  Future<Iterable<model.ReceptionDialplan>> listUsage(String menuName) async =>
      (await _dpStore.list().catchError(_handleError)).where(
          (model.ReceptionDialplan rdp) => rdp.allActions.any(
              (action) => action is model.Ivr && action.menuName == menuName));

  Future<model.IvrMenu> update(model.IvrMenu menu) =>
      _ivrStore.update(menu).catchError(_handleError);

  Future<model.IvrMenu> create(model.IvrMenu menu) =>
      _ivrStore.create(menu).catchError(_handleError);

  Future<model.IvrMenu> get(String menuName) =>
      _ivrStore.get(menuName).catchError(_handleError);

  Future remove(String menuName) =>
      _ivrStore.remove(menuName).catchError(_handleError);
}
