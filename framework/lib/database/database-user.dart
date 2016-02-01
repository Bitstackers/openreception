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
  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  User(this._connection);

  /**
   * Create a single user in the database.
   */
  Future<Model.User> create(Model.User user) async {
    final String sql = '''
iNSERT INTO
  users
    (name, extension, send_from, google_username, google_appcode, enabled)
VALUES
    (@name, @extension, @sendfrom, @googleUsername, @googleAppcode, @enabled)
RETURNING
  id''';

    final Map parameters = {
      'name': user.name,
      'extension': user.peer,
      'sendfrom': user.address,
      'googleUsername': user.googleUsername,
      'googleAppcode': user.googleAppcode,
      'enabled': user.enabled,
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('User not created');
      }

      user.id = rows.first.id;
      return user;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Remove the user with id [userId] from the database
   */
  Future remove(int userId) async {
    String sql = '''
DELETE FROM
  users
WHERE
  id=@id''';

    final Map parameters = {'id': userId};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No user with uid: $userId');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.User> getByIdentity(String identity) async {
    String sql = '''
SELECT
  u.id,
  u.name,
  u.extension,
  u.google_username,
  u.google_appcode,
  u.send_from,
  u.enabled
FROM auth_identities JOIN users u ON auth_identities.user_id = u.id
WHERE identity = @identity''';

    final Map parameters = {'identity': identity};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No user with identity: $identity');
      }

      return _rowToUser(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrive a single user from the database.
   */
  Future<Model.User> get(int userID) async {
    String sql = '''
SELECT
  id,
  name,
  send_from,
  enabled,
  google_username,
  google_appcode,
  extension
FROM
  users
WHERE
  id = @id''';

    final Map parameters = {'id': userID};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No user with uid: $userID');
      }

      return _rowToUser(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Update an exiting user with the data stored in object [user] passed.
   */
  Future<Model.User> update(Model.User user) async {
    String sql = '''
UPDATE
  users
SET
  name=@name,
  extension=@extension,
  send_from=@sendfrom,
  google_username=@googleUsername,
  google_appcode=@googleAppcode,
  enabled=@enabled
WHERE id=@id;
  ''';

    final Map parameters = {
      'name': user.name,
      'extension': user.peer,
      'sendfrom': user.address,
      'googleUsername': user.googleUsername,
      'googleAppcode': user.googleAppcode,
      'enabled': user.enabled,
      'id': user.id
    };

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('User not updated');
      }

      return user;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Returns the groups of user with id [userId].
   */
  Future<Iterable<Model.UserGroup>> userGroups(int userId) async {
    String sql = '''
SELECT
  id,
  name
FROM
  user_groups
JOIN
  groups ON
    user_groups.group_id = groups.id
WHERE
  user_groups.user_id = @userid''';

    final Map parameters = {'userid': userId};

    try {
      return (await _connection.query(sql, parameters)).map(_rowToUserGroup);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Returns group with id [groupId] in the system.
   */
  Future<Model.UserGroup> group(int groupId) async {
    String sql = '''
SELECT
  id,
  name
FROM
  groups
WHERE
  id=@gid''';

    final Map parameters = {'gid': groupId};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No group with gid: $groupId');
      }

      return _rowToUserGroup(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Returns all available groups in the system.
   */
  Future<Iterable<Model.UserGroup>> groups() async {
    String sql = '''
SELECT
  id,
  name
FROM
  groups''';

    try {
      return (await _connection.query(sql)).map(_rowToUserGroup);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Create a new group.
   */
  Future createGroup(String name) async {
    String sql = '''
INSERT INTO
  groups
    (name)
VALUES
    (@name)
RETURNING id''';

    final Map parameters = {'name': name};

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('Group not created');
      }

      return await group(rows.first.id);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Adds user with id [userId] to group with id [groupId].
   */
  Future joinGroup(int userId, int groupId) async {
    String sql = '''
INSERT INTO
  user_groups
    (user_id, group_id)
VALUES
    (@userid, @groupid)''';

    final Map parameters = {'userid': userId, 'groupid': groupId};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.ServerError(
            'User with uid: $userId failed to join group $groupId');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Removes user with id [userId] from group with id [groupId].
   */
  Future leaveGroup(int userId, int groupId) async {
    String sql = '''
DELETE FROM
  user_groups
WHERE
  user_id = @userid
AND
  group_id = @groupid''';

    final Map parameters = {'userid': userId, 'groupid': groupId};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.ServerError(
            'User with uid: $userId failed to leave group $groupId');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Returns the identities of user with id [userId].
   */
  Future<Iterable<Model.UserIdentity>> identities(int userId) async {
    String sql = '''
SELECT
  identity,
  user_id
FROM
  auth_identities
WHERE
  user_id = @userid''';

    final Map parameters = {'userid': userId};

    try {
      return (await _connection.query(sql, parameters)).map(_rowToUserIdentity);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Add a new [UserIndentity] to the database.
   */
  Future<Model.UserIdentity> addIdentity(Model.UserIdentity identity) async {
    String sql = '''
    INSERT INTO auth_identities (identity, user_id)
    VALUES (@identity, @userid)
    RETURNING identity;
  ''';

    final Map parameters = {
      'identity': identity.identity,
      'userid': identity.userId
    };

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.ServerError(
            'User with uid: ${identity.userId} failed to associate '
            'with identity ${identity.identity}');
      }

      return identity;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Remove a [UserIndentity] from the database.
   */
  Future removeIdentity(Model.UserIdentity identity) async {
    String sql = '''
      DELETE FROM auth_identities
      WHERE user_id=@userid AND identity=@identity;
    ''';

    final Map parameters = {
      'userid': identity.userId,
      'identity': identity.identity
    };

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.ServerError(
            'User with uid: ${identity.userId} failed to un-associate '
            'with identity ${identity.identity}');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * List every user in the database.
   */
  Future<Iterable<Model.User>> list() async {
    final String sql = '''
SELECT
  id,
  name,
  send_from,
  enabled,
  google_username,
  google_appcode,
  extension
FROM
  users
WHERE enabled''';

    try {
      return (await _connection.query(sql)).map(_rowToUser);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
