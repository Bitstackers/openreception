part of db;

Future<Map> getDraft() {
  return _pool.connect().then((Connection conn) {
    String sql = '''
SELECT something FROM somewhere''';

    Map parameters = {};

    return conn.query(sql, parameters).toList().then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'contact_id' : row.contact_id};
      }

      return data;
    }).whenComplete(() => conn.close());
  });
}
