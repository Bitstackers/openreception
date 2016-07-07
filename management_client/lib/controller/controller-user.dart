part of management_tool.controller;

class User {
  final service.RESTUserStore _service;
  final model.User _appUser;

  User(this._service, this._appUser);

  Future<Iterable<model.UserReference>> list() =>
      _service.list().catchError(_handleError);

  Future<Iterable<model.UserStatus>> userStatusList() =>
      _service.userStatusList().catchError(_handleError);

  Future<model.UserReference> create(model.User user) =>
      _service.create(user, _appUser).catchError(_handleError);

  Future<model.User> get(int userId) =>
      _service.get(userId).catchError(_handleError);

  Future remove(int userId) =>
      _service.remove(userId, _appUser).catchError(_handleError);

  Future<model.UserReference> update(model.User user) =>
      _service.update(user, _appUser).catchError(_handleError);

  Future<Iterable<String>> groups() =>
      _service.groups().catchError(_handleError);

  Future<Iterable<model.Commit>> changes([int uid]) =>
      _service.changes(uid).catchError(_handleError);

  Future<String> changelog(int uid) =>
      _service.changelog(uid).catchError(_handleError);
}
