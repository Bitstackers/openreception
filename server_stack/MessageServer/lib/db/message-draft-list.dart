part of messageserver.database;

Future<Map> messageDraftList(int offset, int count) {

  final String context = packageName + ".messageDraftList"; 

  String sql = '''
    SELECT id, owner, json
    FROM message_draft
    ORDER BY id
    LIMIT ${count} OFFSET ${offset};''';
    
  Map parameters = {};

  return database.query(_pool, sql, parameters).then((rows) {

    logger.debugContext("Returned ${rows.length} draft items" ,
                         context);  
    
    List draftList = [];
    for(var row in rows) {
      Map draft =
        {'contact_id' : row.id,
         'owner'      : row.owner,
         'json'       : JSON.decode(row.json)};
      draftList.add (draft);
    }

    return {'drafts' : draftList};
  }).catchError((error) {
    logger.errorContext(error, context) ;
  });
}