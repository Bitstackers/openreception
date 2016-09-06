part of management_tool.controller;

class Ivr {
  final service.RESTIvrStore _ivrService;
  final service.RESTDialplanStore _dpService;
  final model.User _modifier;

  Ivr(this._ivrService, this._dpService, this._modifier);

  Future<Iterable<model.IvrMenu>> list() =>
      _ivrService.list().catchError(_handleError);
  Future<Iterable<model.ReceptionDialplan>> listUsage(String menuName) async =>
      (await _dpService.list().catchError(_handleError)).where(
          (model.ReceptionDialplan rdp) => rdp.allActions.any(
              (action) => action is model.Ivr && action.menuName == menuName));

  Future<model.IvrMenu> update(model.IvrMenu menu) =>
      _ivrService.update(menu, _modifier).catchError(_handleError);

  Future<model.IvrMenu> create(model.IvrMenu menu) =>
      _ivrService.create(menu, _modifier).catchError(_handleError);

  Future<model.IvrMenu> get(String menuName) =>
      _ivrService.get(menuName).catchError(_handleError);

  Future remove(String menuName) =>
      _ivrService.remove(menuName, _modifier).catchError(_handleError);

  Future<String> changelog(String menuName) =>
      _ivrService.changelog(menuName).catchError(_handleError);
}
