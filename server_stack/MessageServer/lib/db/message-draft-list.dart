part of messageserver.database;

Future<Map> messageDraftList(int offset, int count) {
  String sql = '''
    SELECT id, owner, json
    FROM message_draft
    ORDER BY id
    LIMIT ${count} OFFSET ${offset};''';
    
  print (sql);

  Map parameters = {};

  return database.query(_pool, sql, parameters).then((rows) {
    List draftList = [];
    for(var row in rows) {
      Map draft =
        {'contact_id' : row.id,
         'owner'      : row.owner,
         'json'       : JSON.decode(row.json)};
      draftList.add (draft);
    }

    return {'drafts' : draftList};
  });
}