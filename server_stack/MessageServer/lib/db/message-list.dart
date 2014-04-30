part of messageserver.database;

Future<Map> messageList() {
  
  int limit = 100;
  String sql = '''
    SELECT
         id, message,
         context_contact_id,
         context_reception_id,
         context_contact_name,
         context_reception_name,
         taken_from, taken_by_agent, created_at,
         (SELECT count(*) FROM message_queue WHERE message_id = messages.id) AS pending_messages
    FROM messages

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
        {'id'                    : row.id,
         'message'               : row.message,
         'context_contact_id'    : row.context_contact_id,
         'context_reception_id'  : row.context_reception_id,
         'context_contact_name'  : row.context_contact_name,
         'context_reception_name': row.context_contact_name,
         'taken_by_agent'        : row.taken_by_agent,
         'created_at'            : createdAt.millisecondsSinceEpoch,
         'pending_messages'      : row.pending_messages};
      messages.add(message);
    }

    return {'messages': messages};
  });
}
