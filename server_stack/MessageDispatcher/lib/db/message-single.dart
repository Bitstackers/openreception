part of messagedispatcher.database;

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

  Map parameters = {'messageID': messageID};

  return database.query(_pool, sql, parameters).then((rows) {
    if (rows.isEmpty) {
      return {};
    }
      var row = rows.first;

      Map message =
        {'id'               : row.id,
         'message'          : row.message,
         'context'          : {'contact'   : {'id' :row.context_contact_id, 'name' : row.context_contact_name},
                               'reception' : {'id' :row.context_reception_id, 'name' : row.context_reception_name}},
         'taken_from'       : {'name'      : row.taken_from_name,
                               'company'   : row.taken_from_company,
                               'phone'     : row.taken_from_phone,
                               'cellphone' : row.taken_from_cellphone},
         'taken_by_agent'   : {'name' : row.taken_by_agent_name, 'id' : row.taken_by_agent_id, 'address' : row.agent_address},
         'flags'            : JSON.decode(row.flags),
         'created_at'       : row.created_at,
         'pending_messages' : row.pending_messages};

    return message;
  });
}

Future<List<Map>> messageRecipients(int messageID) {
  String sql = '''
     SELECT 
       recipient_role    AS role, 
       mr.contact_id     AS contact_id, 
       mr.contact_name   AS contact_name, 
       mr.reception_id   AS reception_id, 
       mr.reception_name AS reception_name, 
       address_type      AS transport, 
       address           AS address
     FROM 
       message_recipients mr
     JOIN 
           messaging_end_points mep ON mr.contact_id = mep.contact_id 
       AND mr.reception_id = mep.reception_id
       AND mep.enabled 
     JOIN 
       messaging_addresses ma ON  ma.id = mep.address_id
     WHERE
         message_id = $messageID;''';

    return database.query(_pool, sql).then((rows) {
      List<Map> recipients = new List<Map>();
      for(var row in rows) {
        recipients.add({'role'      : row.role,
                        'contact'   : { 'id' : row.contact_id,   'name' : row.contact_name},
                        'reception' : { 'id' : row.reception_id, 'name' : row.reception_name},
                        'transport' : row.transport,
                        'address'   : row.address});
      }

      return recipients;
    });
}
