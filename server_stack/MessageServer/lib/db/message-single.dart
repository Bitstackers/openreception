part of messageserver.database;

/**
 * Retrieves a single message from the database.
 */
Future<Map> messageSingle(int messageID) {
  String sql = '''
    SELECT
         id, message, subject, 
         context_contact_id,
         context_reception_id,
         context_contact_name,
         context_reception_name,
         taken_from, taken_by_agent, urgent, created_at,
         (SELECT count(*) FROM message_queue WHERE message_id = messages.id) AS pending_messages
    FROM messages
    WHERE    id = @messageID 
    ORDER BY id DESC;''';

  Map parameters = {"messageID" : messageID};

  return database.query(_pool, sql, parameters).then((rows) {
      var row = rows.first;
      
      DateTime createdAt = row.created_at;
      
      if (createdAt == null) {
        createdAt = new DateTime.fromMillisecondsSinceEpoch(0);
      }
      
      Map message =
        {'id'                    : row.id,
         'message'               : row.message,
         'subject'               : row.subject,
         'context_contact_id'    : row.context_contact_id,
         'context_reception_id'  : row.context_reception_id,
         'context_contact_name'  : row.context_contact_name,
         'context_reception_name': row.context_contact_name,
         'taken_by_agent'        : row.taken_by_agent,
         'urgent'                : row.urgent,
         'created_at'            : createdAt.millisecondsSinceEpoch,
         'pending_messages'      : row.pending_messages};

    return message;
  });
}

/**
 * Fetches the recipients for a message from the database.
 */

Future<List<Map>> messageRecipients(int messageID) {
  String sql = '''
     SELECT 
        contact_id, 
        contact_name, 
        reception_id, 
        reception_name, 
        recipient_role 
     FROM 
        message_recipients 
     WHERE 
        message_id = $messageID;''';
  
  return database.query(_pool, sql).then((rows) {
    List recpients = new List();
    
    for(var row in rows) {
      recpients.add(
          {'role'      : row.recipient_role,
           'contact'   : { 'id'   : row.contact_id, 
                           'name' : row.contact_name},
           'reception' : { 'id'   : row.reception_id,
                           'name' : row.reception_name}
        });
    }

    return recpients;
  });
}    