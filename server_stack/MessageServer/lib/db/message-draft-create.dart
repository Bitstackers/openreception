part of messageserver.database;

/**
 * Creates a draft (JSON encoded document) in the database.
 * 
 * [userID]   The user ID of the user owning the draft.
 * [jsonBody] The draft object to store in the database. 
 * 
 */
Future<Map> messageDraftCreate(int userID, Map jsonBody) {
    
  final String context = packageName + ".createDraft"; 
    
  String sql = '''
        INSERT INTO message_draft
        (owner, json) 
        VALUES 
        (@userID, @jsonBody)
        RETURNING id;''';
    
  Map parameters = {'userID'   : userID,
                    'jsonBody' : JSON.encode (jsonBody)};

  return database.query(_pool, sql, parameters).then((rows) {
    logger.debugContext("Created a new draft for user " + userID.toString(), context);
      
    Map data = {};
      
    if (rows.length > 0) {
      data = {'draft_id': rows.first.id};
    } else {
      throw new CreateFailed("Failed to insert the draft into database.");
    }
      
      return data;
    
    }).catchError((error) {
      logger.errorContext(error, context);
    });
  }
