part of messageserver.database;

Future<Map> messageDraftUpdate(int ID, String jsonBody) {
  String sql = '''
   UPDATE message_draft
      SET json = @jsonBody
    WHERE    id = @draftID;''';

  Map parameters = {'draftID'  : ID,
                    'jsonBody' : jsonBody};

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