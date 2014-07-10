part of utilities.model;

class User {

  static int nullID = 0;

  Map _map = {};
  String       get peer   => this._map['extension'];
  int          get ID     => this._map['id'];
  List<String> get groups => this._map['groups'];

  static Future<User> load (String identity) {
    return UserDatabase.getUser(identity).then((Map userMap) {
      return new User.fromMap (userMap);
    });
  }

  static Future<User> list (String identity) {
    return UserDatabase.getUser(identity).then((Map userMap) {
      return new User.fromMap (userMap);
    });
  }

  User.fromMap (Map userMap) {
    this._map = userMap;
  }

  Map toJson() {
    return this._map;
  }

  bool inAnyGroups(List<String> groupNames) => groupNames.any((g) => groups.contains(g));
}

abstract class UserDatabase {

  static Future<Map> getUser(String userEmail, {Database fromDatabase}) {
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

    Map parameters = {'email' : userEmail};

    return fromDatabase.query(sql, parameters).then((rows) {
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

  static Future<Map> getUserFromId(int userId, {Database fromDatabase}) {
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

      return fromDatabase.query(sql, parameters).then((rows) {
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

  static Future<List<Map>> userList(Database fromDatabase) {
    String sql = '''
  SELECT id, name, extension, 
   (SELECT array_to_json(array_agg(name)) 
    FROM user_groups JOIN groups ON user_groups.group_id = groups.id
    WHERE user_groups.user_id = id) AS groups,
   (SELECT array_to_json(array_agg(identity)) 
    FROM auth_identities 
    WHERE user_id = id) AS identities
  FROM auth_identities JOIN users ON auth_identities.user_id = users.id;''';

    return fromDatabase.query(sql).then((rows) {
      List list = [];
      for (var row in rows) {
        list.add(
          {'id'        : row.id,
           'name'      : row.name,
           'extension' : row.extension,
           'groups'    : JSON.decode(row.groups),
           'identities': JSON.decode(row.identities)});
      };

      return list;
    });
  }
}