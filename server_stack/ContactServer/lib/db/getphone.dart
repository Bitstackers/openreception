part of db;

Future<Map> getPhone(int phoneId) {
  return _pool.connect().then((Connection conn) {
    String sql = '''
SELECT id, kind, value
FROM phone_numbers
WHERE id = @phoneId
''';

    Map parameters = {'phoneId': phoneId};

    return conn.query(sql, parameters).toList().then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'id'   : row.id,
           'type' : row.kind,
           'value': row.value};
      }

      return data;
    }).whenComplete(() => conn.close());
  });
}