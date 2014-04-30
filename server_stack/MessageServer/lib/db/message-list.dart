part of messageserver.database;

Future<Map> messageList() {
  
  int limit = 100;
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
           identity       AS agent_address,
           flags, 
           created_at,
           taken_by_agent AS taken_by_agent_id,
           users.name     AS taken_by_agent_name,
           (SELECT count(*) FROM message_queue AS queue WHERE queue.message_id = message.id) AS pending_messages
      FROM messages message
      LEFT JOIN auth_identities ai ON taken_by_agent = user_id AND ai.send_from
           JOIN users on taken_by_agent = users.id
    ORDER BY 
         message.id    DESC
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
      messages.add(message);
    }

    return {'messages': messages};
  });
}
