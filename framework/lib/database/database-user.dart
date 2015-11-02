/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.database;

/**
 * Database realization of the [User] [Storage] layer.
 */
class User implements Storage.User {
  static const String className = '${libraryName}.User';

  static final Logger log = new Logger(className);

  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  User(this._connection);

  /**
   * Create a single user in the database.
   */
  Future<Model.User> create(Model.User user) {
    String sql = '''
    INSERT INTO users (name, extension, send_from)
    VALUES (@name, @extension, @sendfrom)
    RETURNING id;
  ''';

    Map parameters = {
      'name': user.name,
      'extension': user.peer,
      'sendfrom': user.address
    };

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.isEmpty
            ? throw new Storage.ServerError('User not created')
            : user..ID = rows.first.id)
        .catchError((error, stackTrace) {
      log.severe('sql:$sql \nparameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Remove the user with id [userId] from the database
   */
  Future remove(int userId) {
    String sql = '''
      DELETE FROM users
      WHERE id=@id;
    ''';

    Map parameters = {'id': userId};
    return _connection.execute(sql, parameters)
        .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Retrive a single user from the database.
   */
  Future<Model.User> get(int userID) {
    String sql = '''
SELECT
  outer_user.id,
  outer_user.name,
  outer_user.send_from,
  outer_user.enabled,
  outer_user.extension,
  COALESCE((SELECT array_to_json(array_agg(row_to_json(tmp_groups)))
   FROM 
   (SELECT 
     groups.id, groups.name
    FROM
     users 
    JOIN
     user_groups ON user_groups.user_id = users.id
    JOIN groups ON user_groups.group_id = groups.id
    WHERE user_groups.user_id = outer_user.id
   ) tmp_groups
  ),'[]') AS groups,

  COALESCE((SELECT array_to_json(array_agg(row_to_json(tmp_iden)))
   FROM 
   (SELECT 
     users.id as user_id, 
     auth_identities.identity
    FROM
     users 
    JOIN
      auth_identities ON auth_identities.user_id = users.id
    WHERE auth_identities.user_id = outer_user.id
   ) tmp_iden
  ),'[]') AS identities
FROM
  users as outer_user
WHERE 
  id = @id''';

    Map parameters = {'id': userID};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.isEmpty
            ? new Future.error(new Storage.NotFound('No user with ID $userID'))
            : _rowToUser(rows.first))
        .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe(error);
        log.severe(stackTrace);
        log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);
      }

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Update an exiting user with the data stored in object [user] passed.
   */
  Future<Model.User> update(Model.User user) {
    String sql = '''
    UPDATE users
    SET name=@name, extension=@extension, send_from=@sendfrom
    WHERE id=@id;
  ''';

    Map parameters = {
      'name': user.name,
      'extension': user.peer,
      'sendfrom': user.address,
      'id': user.ID
    };

    return _connection
        .execute(sql, parameters)
        .then((_) => user)
        .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Returns the groups of user with id [userId].
   */
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
      for (var row in rows) {
        userGroups.add(new Model.UserGroup.empty()
          ..id = row.id
          ..name = row.name);
      }
      return userGroups;
    }).catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Returns all available groups in the system.
   */
  Future<Iterable<Model.UserGroup>> groups() {
    String sql = '''
    SELECT id, name
    FROM groups
  ''';

    return _connection.query(sql).then((List rows) {
      List<Model.UserGroup> userGroups = new List<Model.UserGroup>();
      for (var row in rows) {
        userGroups.add(new Model.UserGroup.empty()
          ..id = row.id
          ..name = row.name);
      }
      return userGroups;
    }).catchError((error, stackTrace) {
      log.severe('sql:$sql', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Create a new group.
   */
  Future createGroup(String name) {
    String sql = '''
    INSERT INTO groups (name)
    VALUES (@name)
    RETURNING id
  ''';

    Map parameters = {'name': name};

    return _connection
        .query(sql, parameters)
        .then((row) => new Model.UserGroup.empty()
          ..id = row.id
          ..name = name)
        .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Adds user with id [userId] to group with id [groupId].
   */
  Future joinGroup(int userId, int groupId) {
    String sql = '''
    INSERT INTO user_groups (user_id, group_id)
    VALUES (@userid, @groupid);
  ''';

    Map parameters = {'userid': userId, 'groupid': groupId};

    return _connection.execute(sql, parameters).catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Removes user with id [userId] from group with id [groupId].
   */
  Future leaveGroup(int userId, int groupId) {
    String sql = '''
    DELETE FROM user_groups
    WHERE user_id = @userid AND group_id = @groupid;
  ''';

    Map parameters = {'userid': userId, 'groupid': groupId};

    return _connection.execute(sql, parameters).catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Returns the identities of user with id [userId].
   */
  Future<Iterable<Model.UserIdentity>> identities(int userId) {
    String sql = '''
    SELECT identity, user_id
    FROM auth_identities
    WHERE user_id = @userid
  ''';

    Map parameters = {'userid': userId};

    return _connection.query(sql, parameters).then((List rows) {
      List<Model.UserIdentity> userIdentities = new List<Model.UserIdentity>();
      for (var row in rows) {
        userIdentities.add(new Model.UserIdentity.empty()
          ..identity = row.identity
          ..userId = row.user_id);
      }
      return userIdentities;
    }).catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Add a new [UserIndentity] to the database.
   */
  Future<Model.UserIdentity> addIdentity(Model.UserIdentity identity) {
    String sql = '''
    INSERT INTO auth_identities (identity, user_id)
    VALUES (@identity, @userid)
    RETURNING identity;
  ''';

    Map parameters = {'identity': identity.identity, 'userid': identity.userId};

    return _connection
        .query(sql, parameters)
        .then((rows) => new Model.UserIdentity.empty()
          ..identity = rows.first.identity
          ..userId = identity.userId)
        .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Remove a [UserIndentity] from the database.
   */
  Future removeIdentity(Model.UserIdentity identity) {
    String sql = '''
      DELETE FROM auth_identities
      WHERE user_id=@userid AND identity=@identity;
    ''';

    Map parameters = {'userid': identity.userId, 'identity': identity.identity};

    return _connection.execute(sql, parameters).catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * List every user in the database.
   */
  Future<Iterable<Model.User>> list() {
    final String sql = '''
SELECT
  outer_user.id,
  outer_user.name,
  outer_user.send_from,
  outer_user.enabled,
  outer_user.extension,
  COALESCE((SELECT array_to_json(array_agg(row_to_json(tmp_groups)))
   FROM 
   (SELECT 
     groups.id, groups.name
    FROM
     users 
    JOIN
     user_groups ON user_groups.user_id = users.id
    JOIN groups ON user_groups.group_id = groups.id
    WHERE user_groups.user_id = outer_user.id
   ) tmp_groups
  ),'[]') AS groups,

  COALESCE((SELECT array_to_json(array_agg(row_to_json(tmp_iden)))
   FROM 
   (SELECT 
     users.id as user_id, 
     auth_identities.identity
    FROM
     users 
    JOIN
      auth_identities ON auth_identities.user_id = users.id
    WHERE auth_identities.user_id = outer_user.id
   ) tmp_iden
  ),'[]') AS identities
FROM
  users as outer_user
WHERE enabled
''';

    return _connection
        .query(sql)
        .then((Iterable rows) => rows.map(_rowToUser))
        .catchError((error, stackTrace) {
      log.severe('$sql', error, stackTrace);
      return new Future.error(error, stackTrace);
    });
  }
}
