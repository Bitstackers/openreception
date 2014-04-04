part of messageserver.database;

Future<Map> messageDraftCreate(int userID, String jsonBody) {
    final String context = packageName + ".createDraft"; 
    
    String sql = '''
        INSERT INTO message_draft
        (owner, json) 
        VALUES 
        (@userID, @jsonBody)
        RETURNING id;''';
    
    Map parameters = {'userID'   : userID,
                      'jsonBody' : jsonBody};

    return database.query(_pool, sql, parameters).then((rows) {
      logger.debugContext("Created a new draft for user " + userID.toString(), context);
      
      Map data = {};
      
      if (rows.length > 0) {
        data = {'draft_id': rows.first.id};
      } else {
        throw new NotFound("Failed to insert the draft into database.");
        //TODO: Throw createFailed exception 
      }
      
      return data;
    
    }).catchError((error) {
      log(sql);
      throw error;
    });
  }
