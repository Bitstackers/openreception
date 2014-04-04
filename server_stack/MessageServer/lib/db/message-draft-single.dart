part of messageserver.database;

Future<Map> messageDraftSingle(int ID) {
  String sql = '''
    SELECT id, owner, json
    FROM message_draft
    WHERE    id = $ID
    ORDER BY id DESC;''';

  Map parameters = {};

  return database.query(_pool, sql, parameters).then((rows) {
    Map data = {};
    
    if (rows.length == 0 ) {
      throw new NotFound('No draft found with ID ${ID}.');
    }
    
      var row = rows.first;
      data =
        {'contact_id' : row.id,
         'owner'      : row.owner,
         'json'       : JSON.decode(row.json)};

    return data;
  });
}