part of db;

Future<Map> getPhone(int phoneId) {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
SELECT id, kind, value
FROM phone_numbers
WHERE id = @phoneId
''';

    Map parameters = {'phoneId': phoneId};

    conn.query(sql, parameters).toList().then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'id'   : row.id,
           'type' : row.kind,
           'value': row.value};
      }

      completer.complete(data);
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());
  }).catchError((err) => completer.completeError(err));

  return completer.future;
}