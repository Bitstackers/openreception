part of management_tool.controller;

class User {
  final service.RESTUserStore _service;

  User(this._service);

  Future<Iterable<model.User>> list() => _service.list();

  Future<model.User> create(model.User user) => _service.create(user);

  Future<model.User> get(int userId) => _service.get(userId);

  Future remove(int userId) => _service.remove(userId);

  Future<model.User> update(model.User user) => _service.update(user);

  Future<Iterable<model.UserGroup>> userGroups(int userID) =>
      _service.userGroups(userID);

  Future<Iterable<model.UserGroup>> groups() => _service.groups();

  Future<Iterable<model.UserIdentity>> identities(int userId) =>
      _service.identities(userId);

  Future joinGroup(int userId, int groupId) =>
      _service.joinGroup(userId, groupId);

  Future leaveGroup(int userId, int groupId) =>
      _service.leaveGroup(userId, groupId);

  Future<model.UserIdentity> addIdentity(model.UserIdentity identity) =>
      _service.addIdentity(identity);

  Future removeIdentity(model.UserIdentity identity) =>
      _service.removeIdentity(identity);
}
