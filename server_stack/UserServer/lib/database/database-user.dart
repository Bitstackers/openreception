part of userserver.database;

abstract class User {


  static Future<List<Map>> oldList() {

    const String sql = "SELECT * FROM USERS";

    return database.query(_pool, sql).then((rows) {
      List<Map> users = new List<Map>();
      return Future.forEach(rows, (var row) {

        return User._groups(row.id).then((List<Map> groups) {

          return User._auth_identities(row.id).then((List<String> authIdentities) {
                                users.add({'id'     : row.id,
                                 'name'   : row.name,
                                 'groups' : groups,
                                 'auth_identities' : authIdentities});
          });

        });

      }).then((_) => users);
    });
  }

  static Future<List<Model.User>> list() {

    const String sql = "SELECT * FROM USERS";

    return database.query(_pool, sql).then((rows) {
      List<Map> users = new List<Map>();
      return Future.forEach(rows, (var row) {

        return User._groups(row.id).then((List<Map> groups) {

          return User._auth_identities(row.id).then((List<String> authIdentities) {
                                users.add({'id'     : row.id,
                                 'name'   : row.name,
                                 'groups' : groups,
                                 'auth_identities' : authIdentities});
          });

        });

      }).then((_) => users);
    });
  }

  static Future<List<Model.User>> listPGJSON() {

    const String sql =
'''${SQLMacros}
SELECT 
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

    return database.query(_pool, sql).then((rows) {
      List<Map> users = new List<Map>();

      for(var row in rows) {
         users.add(
         {'id'     : row.id,
         'name'       : row.name,
         'send_from'  : row.send_from,
         'extension'  : row.extension,
         'groups'     : groups,
         'identities' : identities});
      }

      return users;

    });
  }

  static Future<List<Map>> _groups(int uid) {
    final String sql = "SELECT id, name FROM user_groups JOIN groups ON groups.id = user_groups.group_id WHERE user_id = ${uid}";

    return database.query(_pool, sql).then((rows) {
      List<Map> groups = new List<Map>();
      for(var row in rows) {
        groups.add({'id'     : row.id,
                    'name'   : row.name});
       }

      return groups;
    });
  }

  static Future<List<String>> _auth_identities(int uid) {
    final String sql = "SELECT identity FROM auth_identities JOIN users ON users.id = auth_identities.user_id WHERE user_id = ${uid}";

    return database.query(_pool, sql).then((rows) {
      List<String> identities = new List<String>();
      for(var row in rows) {
        identities.add(row.identity);
       }

      return identities;
    });
  }

}