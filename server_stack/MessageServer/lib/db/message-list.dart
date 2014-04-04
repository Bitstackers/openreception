part of messageserver.database;

Future<Map> messageList() {
  
  int limit = 100;
  String sql = '''
    SELECT 
         id, message, subject, to_contact_id, taken_from, taken_by_agent, urgent, created_at,
         (SELECT count(*) FROM message_queue WHERE message_id = message.id) AS pending_messages 

    FROM message

    ORDER BY created_at DESC
        LIMIT ${limit} 
  ''';

  return database.query(_pool, sql).then((rows) {
    List messages = new List();
    
    for(var row in rows) {
      
      DateTime createdAt = row.created_at;
      
      if (createdAt == null) {
        createdAt = new DateTime.fromMillisecondsSinceEpoch(0);
      }
                  
      Map message =
        {'id'               : row.id,
         'message'          : row.message,
         'subject'          : row.subject,
         'to_contact_id'    : row.to_contact_id,
         'taken_from'       : row.taken_from,
         'taken_by_agent'   : row.taken_by_agent,
         'urgent'           : row.urgent,
         'created_at'       : createdAt.millisecondsSinceEpoch,
         'pending_messages' : row.pending_messages};
      messages.add(message);
    }

    return {'messages': messages};
  });
}
