part of adaheads.server.database;

Future<int> _createUser(Pool pool, String name, String extension) {
  String sql = '''
    INSERT INTO users (name, extension)
    VALUES (@name, @extension)
    RETURNING id;
  ''';

  Map parameters =
    {'name'      : name,
     'extension' : extension};

  return query(pool, sql, parameters).then((rows) => rows.first.id);
}

Future<int> _deleteUser(Pool pool, int userId) {
  String sql = '''
      DELETE FROM users
      WHERE id=@id;
    ''';

  Map parameters = {'id': userId};
  return execute(pool, sql, parameters);
}

Future<model.User> _getUser(Pool pool, int userId) {
  String sql = '''
    SELECT id, name, extension
    FROM users
    WHERE id = @id
  ''';

  Map parameters = {'id': userId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new model.User(row.id, row.name, row.extension);
    }
  });
}

Future<List<model.User>> _getUserList(Pool pool) {
  String sql = '''
    SELECT id, name, extension
    FROM users
  ''';

  return query(pool, sql).then((rows) {
    List<model.User> users = new List<model.User>();
    for(var row in rows) {
      users.add(new model.User(row.id, row.name, row.extension));
    }
    return users;
  });
}

Future<int> _updateUser(Pool pool, int userId, String name, String extension) {
  String sql = '''
    UPDATE users
    SET name=@name, extension=@extension
    WHERE id=@id;
  ''';

  Map parameters =
    {'name'      : name,
     'extension' : extension,
     'id'        : userId};

  return execute(pool, sql, parameters);
}

Future<List<model.UserGroup>> _getUserGroups(Pool pool, int userId) {
  String sql = '''
    SELECT id, name
    FROM user_groups 
     JOIN groups on user_groups.group_id = groups.id
    WHERE user_groups.user_id = @userid
  ''';

  Map parameters =
    {'userid': userId};

  return query(pool, sql, parameters)
    .then((rows) {
      List<model.UserGroup> userGroups = new List<model.UserGroup>();
      for(var row in rows) {
        userGroups.add(new model.UserGroup(row.id, row.name));
      }
      return userGroups;
    });
}

Future<List<model.UserGroup>> _getGroupList(Pool pool) {
  String sql = '''
    SELECT id, name
    FROM groups
  ''';

  return query(pool, sql).then((rows) {
    List<model.UserGroup> userGroups = new List<model.UserGroup>();
    for(var row in rows) {
      userGroups.add(new model.UserGroup(row.id, row.name));
    }
    return userGroups;
  });
}

Future<int> _joinUserGroup(Pool pool, int userId, int groupId) {
  String sql = '''
    INSERT INTO user_groups (user_id, group_id)
    VALUES (@userid, @groupid);
  ''';

  Map parameters =
    {'userid'  : userId,
     'groupid' : groupId};

  return execute(pool, sql, parameters);
}

Future<int> _leaveUserGroup(Pool pool, int userId, int groupId) {
  String sql = '''
    DELETE FROM user_groups
    WHERE user_id = @userid AND group_id = @groupid;
  ''';

  Map parameters =
    {'userid'  : userId,
     'groupid' : groupId};

  return execute(pool, sql, parameters);
}
