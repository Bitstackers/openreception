part of adaheads.server.database;

Future<int> _createUser(ORDatabase.Connection connection, String name, String extension, String sendFrom) {
  String sql = '''
    INSERT INTO users (name, extension, send_from)
    VALUES (@name, @extension, @sendfrom)
    RETURNING id;
  ''';

  Map parameters =
    {'name'      : name,
     'extension' : extension,
     'sendfrom'  : sendFrom};

  return connection.query( sql, parameters).then((rows) => rows.first.id);
}

Future<int> _deleteUser(ORDatabase.Connection connection, int userId) {
  String sql = '''
      DELETE FROM users
      WHERE id=@id;
    ''';

  Map parameters = {'id': userId};
  return connection.execute(sql, parameters);
}

Future<model.User> _getUser(ORDatabase.Connection connection, int userId) {
  String sql = '''
    SELECT id, name, extension, send_from
    FROM users
    WHERE id = @id
  ''';

  Map parameters = {'id': userId};

  return connection.query(sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      var row = rows.first;
      return new model.User(row.id, row.name, row.extension, row.send_from);
    }
  });
}

Future<List<model.User>> _getUserList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT id, name, extension, send_from
    FROM users
  ''';

  return connection.query(sql).then((List rows) {
    List<model.User> users = new List<model.User>();
    for(var row in rows) {
      users.add(new model.User(row.id, row.name, row.extension, row.send_from));
    }
    return users;
  });
}

Future<int> _updateUser(ORDatabase.Connection connection, int userId, String name, String extension, String sendFrom) {
  String sql = '''
    UPDATE users
    SET name=@name, extension=@extension, send_from=@sendfrom
    WHERE id=@id;
  ''';

  Map parameters =
    {'name'      : name,
     'extension' : extension,
     'sendfrom'  : sendFrom,
     'id'        : userId};

  return connection.execute(sql, parameters);
}

Future<List<model.UserGroup>> _getUserGroups(ORDatabase.Connection connection, int userId) {
  String sql = '''
    SELECT id, name
    FROM user_groups 
     JOIN groups on user_groups.group_id = groups.id
    WHERE user_groups.user_id = @userid
  ''';

  Map parameters = {'userid': userId};

  return connection.query(sql, parameters).then((List rows) {
      List<model.UserGroup> userGroups = new List<model.UserGroup>();
      for(var row in rows) {
        userGroups.add(new model.UserGroup(row.id, row.name));
      }
      return userGroups;
    });
}

Future<List<model.UserGroup>> _getGroupList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT id, name
    FROM groups
  ''';

  return connection.query(sql).then((List rows) {
    List<model.UserGroup> userGroups = new List<model.UserGroup>();
    for(var row in rows) {
      userGroups.add(new model.UserGroup(row.id, row.name));
    }
    return userGroups;
  });
}

Future<int> _joinUserGroup(ORDatabase.Connection connection, int userId, int groupId) {
  String sql = '''
    INSERT INTO user_groups (user_id, group_id)
    VALUES (@userid, @groupid);
  ''';

  Map parameters =
    {'userid'  : userId,
     'groupid' : groupId};

  return connection.execute(sql, parameters);
}

Future<int> _leaveUserGroup(ORDatabase.Connection connection, int userId, int groupId) {
  String sql = '''
    DELETE FROM user_groups
    WHERE user_id = @userid AND group_id = @groupid;
  ''';

  Map parameters =
    {'userid'  : userId,
     'groupid' : groupId};

  return connection.execute(sql, parameters);
}

Future<List<model.UserIdentity>> _getUserIdentityList(ORDatabase.Connection connection, int userId) {
  String sql = '''
    SELECT identity, user_id
    FROM auth_identities
    WHERE user_id = @userid
  ''';

  Map parameters = {'userid': userId};

  return connection.query(sql, parameters).then((List rows) {
    List<model.UserIdentity> userIdentities = new List<model.UserIdentity>();
    for(var row in rows) {
      userIdentities.add(new model.UserIdentity(row.identity, row.user_id));
    }
    return userIdentities;
  });
}

Future<String> _createUserIdentity(ORDatabase.Connection connection, int userId, String identity) {
  String sql = '''
    INSERT INTO auth_identities (identity, user_id)
    VALUES (@identity, @userid)
    RETURNING identity;
  ''';

  Map parameters =
    {'identity' : identity,
     'userid'   : userId};

  return connection.query(sql, parameters).then((rows) => rows.first.identity);
}

Future<int> _updateUserIdentity(ORDatabase.Connection connection, int userIdKey, String identityIdKey,
    String identityIdValue, int userIdValue) {
  String sql = '''
    UPDATE auth_identities
    SET identity = @identityvalye, user_id = @useridvalue
    WHERE user_id = @useridkey AND identity = @identitykey;
  ''';

  Map parameters =
    {'useridkey'     : userIdKey,
     'identitykey'   : identityIdKey,
     'identityvalye' : identityIdValue,
     'useridvalue'   : userIdValue};

  return connection.execute(sql, parameters);
}

Future<int> _deleteUserIdentity(ORDatabase.Connection connection, int userId, String identityId) {
  String sql = '''
      DELETE FROM auth_identities
      WHERE user_id=@userid AND identity=@identity;
    ''';

  Map parameters =
    {'userid': userId,
     'identity': identityId};

  return connection.execute(sql, parameters);
}
