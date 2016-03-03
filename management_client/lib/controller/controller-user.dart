part of management_tool.controller;

class User {
  final service.RESTUserStore _service;
  final model.User _appUser;

  User(this._service, this._appUser);

  Future<Iterable<model.UserReference>> list() => _service.list();

  Future<model.UserReference> create(model.User user) =>
      _service.create(user, _appUser);

  Future<model.User> get(int userId) => _service.get(userId);

  Future remove(int userId) => _service.remove(userId, _appUser);

  Future<model.UserReference> update(model.User user) =>
      _service.update(user, _appUser);

  Future<Iterable<String>> groups() => _service.groups();
}
