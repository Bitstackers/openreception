part of messageserver.database;

Future<Map> getDraft() {
  int limit = 100;
  String sql = '''
    SELECT id, owner, json
    FROM message_draft
    ORDER BY id
    LIMIT ${limit};''';

  Map parameters = {};

  return database.query(_pool, sql, parameters).then((rows) {
    Map data = {};
    if(rows.length == 1) {
      var row = rows.first;
      data =
        {'contact_id' : row.id,
         'owner'      : row.owner,
         'json'       : JSON.decode(row.json)};
    }

    return data;
  });
}
