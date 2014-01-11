part of contactserver.database;

Future<Map> getPhone(int phoneId) {
  String sql = '''
    SELECT id, kind, value
    FROM phone_numbers
    WHERE id = @phoneId''';

  Map parameters = {'phoneId': phoneId};

  return database.query(_pool, sql, parameters).then((rows) {
    Map data = {};
    if(rows.length == 1) {
      var row = rows.first;
      data =
        {'id'   : row.id,
         'type' : row.kind,
         'value': row.value};
    }

    return data;
  });
}