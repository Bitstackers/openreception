part of openreception.database;

class User implements Storage.User {

  static const String className = '${libraryName}.User';

  static final Logger log = new Logger(className);

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

  Connection _database;

  User (this._database);

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

    return this._database.query(sql, parameters).then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'id'        : row.id,
           'name'      : row.name,
           'extension' : row.extension,
           'groups'    : JSON.decode(row.groups),
           'identities': JSON.decode(row.identities)};
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

      return this._database.query(sql, parameters).then((rows) {
        Map data = {};
        if(rows.length == 1) {
          var row = rows.first;
          data =
            {'id'        : row.id,
             'name'      : row.name,
             'extension' : row.extension,
             'groups'    : JSON.decode(row.groups),
             'identities': JSON.decode(row.identities)};
        }

        return data;
      });
    }

  Future<List<Map>> userList() {
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


    return this._database.query(sql).then((rows) {
      List users = [];

      for (var row in rows) {

        List <String> groups     = JSON.decode(row.groups);
        List <String> identities = JSON.decode(row.identities);

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
        {'id'     : row.id,
        'name'       : row.name,
        'send_from'  : row.send_from,
        'extension'  : row.extension,
        'groups'     : groups,
        'identities' : identities});
      };

      return users;
    });
  }
}