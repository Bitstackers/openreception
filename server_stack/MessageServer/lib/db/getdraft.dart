part of messageserver.database;

Future<Map> getDraft() {
  String sql = '''
    SELECT something FROM somewhere''';

  Map parameters = {};

  return database.query(_pool, sql, parameters).then((rows) {
    Map data = {};
    if(rows.length == 1) {
      var row = rows.first;
      data =
        {'contact_id' : row.contact_id};
    }

    return data;
  });
}
