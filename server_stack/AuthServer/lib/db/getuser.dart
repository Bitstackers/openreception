part of authenticationserver.database;

Future<Map> getUser(String userEmail) {
  String sql = '''
SELECT u.id, u.name, u.extension, 
  coalesce (
    (SELECT array_to_json(array_agg(name)) 
     FROM user_groups JOIN groups ON user_groups.group_id = groups.id
     WHERE user_groups.user_id = u.id), 
    '[]') AS groups,
  (SELECT array_to_json(array_agg(identity)) 
   FROM auth_identities 
   WHERE user_id = u.id) AS identities
FROM auth_identities JOIN users u ON auth_identities.user_id = u.id 
WHERE identity = @email;''';

  Map parameters = {'email' : userEmail};

  return connection.query(sql, parameters).then((rows) {
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
