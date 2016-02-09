part of management_tool.controller;

class User {
  final ORService.RESTUserStore _service;

  User(this._service);

  Future<Iterable<ORModel.User>> list() => _service.list();

  Future<ORModel.User> create(ORModel.User user) => _service.create(user);

  Future<ORModel.User> get(int userId) => _service.get(userId);

  Future remove(int userId) => _service.remove(userId);

  Future<ORModel.User> update(ORModel.User user) => _service.update(user);

  Future<Iterable<ORModel.UserGroup>> userGroups(int userID) =>
      _service.userGroups(userID);

  Future<Iterable<ORModel.UserGroup>> groups() => _service.groups();

  Future<Iterable<ORModel.UserIdentity>> identities(int userId) =>
      _service.identities(userId);

  Future joinGroup(int userId, int groupId) =>
      _service.joinGroup(userId, groupId);

  Future leaveGroup(int userId, int groupId) =>
      _service.leaveGroup(userId, groupId);

  Future<ORModel.UserIdentity> addIdentity(ORModel.UserIdentity identity) =>
      _service.addIdentity(identity);

  Future removeIdentity(ORModel.UserIdentity identity) =>
      _service.removeIdentity(identity);
}
