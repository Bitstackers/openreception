part of messageserver.database;

/**
 * Retrieves a single message from the database.
 */
/**
 * XXX: We assume that the identity of the user (from auth_identities table) is an email.
 */
Future<Map> messageSingle(int messageID) {
  String sql = '''
      SELECT
           message.id,
           message, 
           context_contact_id,
           context_reception_id,
           context_contact_name,
           context_reception_name,
           taken_from_name,
           taken_from_company,
           taken_from_phone,
           taken_from_cellphone,
           send_from      AS agent_address,
           flags, 
           created_at,
           taken_by_agent AS taken_by_agent_id,
           users.name     AS taken_by_agent_name,
           (SELECT count(*) FROM message_queue AS queue WHERE queue.message_id = message.id) AS pending_messages
      FROM messages message
           JOIN users on taken_by_agent = users.id
    WHERE    message.id = @messageID
    ORDER BY 
         message.id    DESC;''';

  Map parameters = {'messageID' : messageID};

  return database.query(_pool, sql, parameters).then((rows) {
    if (rows.isEmpty) {
      return {};
    }
    
      var row = rows.first;
      
      DateTime createdAt = row.created_at;
      
      if (createdAt == null) {
        createdAt = new DateTime.fromMillisecondsSinceEpoch(0);
      }

      Map message =
        {'id'                    : row.id,
         'message'               : row.message,
         'context'               : {'contact'   : 
                                     {'id'   : row.context_contact_id, 
                                      'name' : row.context_contact_name},
                                    'reception' : 
                                     {'id'   : row.context_reception_id, 
                                      'name' : row.context_reception_name}},
         'taken_by_agent'        : {'name'    : row.taken_by_agent_name, 
                                    'id'      : row.taken_by_agent_id, 
                                    'address' : row.agent_address},
         'caller'                : {'name'      : row.taken_from_name,
                                    'company'   : row.taken_from_company,
                                    'phone'     : row.taken_from_phone,
                                    'cellphone' : row.taken_from_cellphone},
         'flags'                 : JSON.decode(row.flags),
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
