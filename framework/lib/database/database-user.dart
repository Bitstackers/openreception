part of openreception.database;

class User implements Storage.User {

  static const String className = '${libraryName}.User';

  static final Logger log = new Logger(className);

  final Connection _connection;

  User(this._connection);

  static const String SQLMacros = '''
    WITH groups_of_user AS (
    SELECT
      users.id as uid,
      array_agg(groups.name) as groups
    FROM
      users 
    LEFT JOIN
      user_groups ON user_groups.user_id = users.id
    LEFT JOIN groups ON user_groups.group_id = groups.id
    GROUP BY 
      users.id
    ),
    identities_of_user AS (
    SELECT
      users.id as uid,
      array_agg(auth_identities.identity) as identities
    FROM
      users 
    LEFT JOIN
      auth_identities ON auth_identities.user_id = users.id
    GROUP BY 
      users.id
    )''';

  Future<Model.User> create(Model.User user) {
    String sql = '''
    INSERT INTO users (name, extension, send_from)
    VALUES (@name, @extension, @sendfrom)
    RETURNING id;
  ''';

    Map parameters =
      {'name'      : user.name,
       'extension' : user.peer,
       'sendfrom'  : user.address};

    return _connection.query( sql, parameters)
        .then((rows) =>
            user..ID = rows.first.id);
  }

  Future remove(Model.User user) {
    String sql = '''
      DELETE FROM users
      WHERE id=@id;
    ''';

    Map parameters = {'id': user.ID};
    return _connection.execute(sql, parameters);
  }

  Future<Model.User> getByID(int userId) {
    String sql = '''
    SELECT id, name, extension, send_from
    FROM users
    WHERE id = @id
  ''';

    Map parameters = {'id': userId};

    return _connection.query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        var row = rows.first;
        return new Model.User.empty()
          ..ID = row.id
          ..name = row.name
          ..peer = row.extension
          ..address = row.send_from;
      }
    });
  }

  Future<Model.User> update(Model.User user) {
    String sql = '''
    UPDATE users
    SET name=@name, extension=@extension, send_from=@sendfrom
    WHERE id=@id;
  ''';

    Map parameters =
      {'name'      : user.name,
       'extension' : user.peer,
       'sendfrom'  : user.address,
       'id'        : user.ID};

    return _connection.execute(sql, parameters).then((_) => user);
  }

  Future<Iterable<Model.UserGroup>> userGroups(int userId) {
    String sql = '''
    SELECT id, name
    FROM user_groups 
     JOIN groups on user_groups.group_id = groups.id
    WHERE user_groups.user_id = @userid
  ''';

    Map parameters = {'userid': userId};

    return _connection.query(sql, parameters).then((Iterable rows) {
        List<Model.UserGroup> userGroups = [];
        for(var row in rows) {
          userGroups.add(new Model.UserGroup.empty()
           ..id = row.id
           ..name = row.name);
        }
        return userGroups;
      });
  }

  Future<Iterable<Model.UserGroup>> groups() {
    String sql = '''
    SELECT id, name
    FROM groups
  ''';

    return _connection.query(sql).then((List rows) {
      List<Model.UserGroup> userGroups = new List<Model.UserGroup>();
      for(var row in rows) {
        userGroups.add(new Model.UserGroup.empty()
         ..id = row.id
         ..name = row.name);
      }
      return userGroups;
    });
  }

  Future joinGroup(int userId, int groupId) {
    String sql = '''
    INSERT INTO user_groups (user_id, group_id)
    VALUES (@userid, @groupid);
  ''';

    Map parameters =
      {'userid'  : userId,
       'groupid' : groupId};

    return _connection.execute(sql, parameters);
  }

  Future leaveGroup(int userId, int groupId) {
    String sql = '''
    DELETE FROM user_groups
    WHERE user_id = @userid AND group_id = @groupid;
  ''';

    Map parameters =
      {'userid'  : userId,
       'groupid' : groupId};

    return _connection.execute(sql, parameters);
  }

  Future<Iterable<Model.UserIdentity>> identities(int userId) {
    String sql = '''
    SELECT identity, user_id
    FROM auth_identities
    WHERE user_id = @userid
  ''';

    Map parameters = {'userid': userId};

    return _connection.query(sql, parameters).then((List rows) {
      List<Model.UserIdentity> userIdentities = new List<Model.UserIdentity>();
      for(var row in rows) {
        userIdentities.add(new Model.UserIdentity.empty()
          ..identity = row.identity
          ..userId = row.user_id);
      }
      return userIdentities;
    });
  }

  Future<Model.UserIdentity> addIdentity(Model.UserIdentity identity) {
    String sql = '''
    INSERT INTO auth_identities (identity, user_id)
    VALUES (@identity, @userid)
    RETURNING identity;
  ''';

    Map parameters =
      {'identity' : identity.identity,
       'userid'   : identity.userId};

    return _connection.query(sql, parameters).then((rows) =>
        new Model.UserIdentity.empty()
        ..identity = rows.first.identity
        ..userId = identity.userId);
  }

  Future removeIdentity(Model.UserIdentity identity) {
    String sql = '''
      DELETE FROM auth_identities
      WHERE user_id=@userid AND identity=@identity;
    ''';

    Map parameters =
      {'userid': identity.userId,
       'identity': identity.identity};

    return _connection.execute(sql, parameters);
  }

  Future<Model.User> get(String identity) {
    String sql = '''
    SELECT id, name, extension, 
     (SELECT array_to_json(array_agg(name)) 
      FROM user_groups JOIN groups ON user_groups.group_id = groups.id
      WHERE user_groups.user_id = id) AS groups,
     (SELECT array_to_json(array_agg(identity)) 
      FROM auth_identities 
      WHERE user_id = id) AS identities
    FROM auth_identities JOIN users ON auth_identities.user_id = users.id 
    WHERE identity = @email;''';

    Map parameters = {'email' : identity};

    return this._connection.query(sql, parameters).then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'id'        : row.id,
           'name'      : row.name,
           'extension' : row.extension,
           'groups'    : row.groups,
           'identities': row.identities};
      }

      return data;
    });
  }

  Future<Map> getUserFromId(int userId) {
      String sql = '''
    SELECT id, name, extension, 
     (SELECT array_to_json(array_agg(name)) 
      FROM user_groups JOIN groups ON user_groups.group_id = groups.id
      WHERE user_groups.user_id = id) AS groups,
     (SELECT array_to_json(array_agg(identity)) 
      FROM auth_identities 
      WHERE user_id = id) AS identities
    FROM auth_identities JOIN users ON auth_identities.user_id = users.id 
    WHERE id = @userid;''';

      Map parameters = {'userid' : userId};

      return _connection.query(sql, parameters).then((rows) {
        Map data = {};
        if(rows.length == 1) {
          var row = rows.first;
          data =
            {'id'        : row.id,
             'name'      : row.name,
             'extension' : row.extension,
             'groups'    : row.groups,
             'identities': row.identities};
        }

        return data;
      });
    }

  Future<Iterable<Model.User>> list() {
    const String sql =
'''${SQLMacros}
SELECT
  users.id, 
  users.name,
  users.send_from,
  users.extension,
  array_to_json(groups_of_user.groups) AS groups,
  array_to_json(identities_of_user.identities) AS identities FROM
  users
JOIN 
  groups_of_user     ON users.id = groups_of_user.uid
JOIN 
  identities_of_user ON users.id = identities_of_user.uid
''';


    return _connection.query(sql).then((rows) {
      List<Model.User> users = [];

      for (var row in rows) {

        List <String> groups     = row.groups;
        List <String> identities = row.identities;

        /// Hotfixing Postgres returning a list containg null instead
        /// of an empty list.
        if (groups.isNotEmpty) {
          if (groups.first == null) {
            groups = [];
          }
        }
        if (identities.isNotEmpty) {
          if (identities.first == null) {
            identities = [];
          }
        }

        users.add(
            new Model.User.empty()
              ..ID = row.id
              ..name = row.name
              ..address = row.send_from
              ..peer = row.extension
              ..groups = groups
              ..identities = identities);
      };

      return users;
    });
  }
}