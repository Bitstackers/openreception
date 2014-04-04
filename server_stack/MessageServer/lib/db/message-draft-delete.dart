part of messageserver.database;

Future<Map> messageDraftDelete(int ID) {
  
  final String context = packageName + ".deleteDraft"; 
  
  String sql = '''
    DELETE FROM 
           message_draft 
    WHERE id    = $ID''';

  return database.execute(_pool, sql).then((int rowsAffected) {
    if (rowsAffected == 0) {
      logger.debugContext("Could not find a draft with ID " + ID.toString(),
                           context);  
      //TODO: Throw notFound exception.
    } else {
      logger.debugContext("Deleted draft with ID " + ID.toString(),
                           context);  
    }
    return rowsAffected;
  }).catchError((error) {
    throw error;
  });
}
