part of openreception.storage;

abstract class User {

  Future<Model.User> get (String identity);

  Future<Iterable<Model.User>> list();

  Future<Model.User> create(Model.User user);

  Future<Model.User> update(Model.User user);

  Future remove(Model.User user);

  Future<Iterable<Model.UserGroup>> userGroups(int userId);

  Future<Iterable<Model.UserGroup>> groups();

  Future joinGroup(int userId, int groupId);

  Future leaveGroup(int userId, int groupId);

  Future<Iterable<Model.UserIdentity>> identities(int userId);

  Future<Model.UserIdentity> addIdentity(Model.UserIdentity identity);

  Future removeIdentity(Model.UserIdentity identity);
}