part of authenticationserver.database;

Future<Map> getUser(String userEmail) {
  String sql = '''
  SELECT id, name, extension, 
   (SELECT array_to_json(array_agg(name)) 
    FROM user_groups JOIN groups ON user_groups.gid = groups.id
    WHERE user_groups.uid = id) AS groups,
   (SELECT array_to_json(array_agg(identity)) 
    FROM auth_identities 
    WHERE user_id = id) AS identities
  FROM auth_identities JOIN users ON auth_identities.user_id = users.id 
  WHERE identity = @email;''';
  
  Map parameters = {'email' : userEmail};
  
  return database.query(_pool, sql, parameters).then((rows) {
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
