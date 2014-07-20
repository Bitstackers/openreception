part of messageserver.database;

Future<Map> createSendMessage(String message, MessageRecipient messageContext, Map callee, int takenByAgentID, List flags) {
  String sql = '''
    INSERT INTO messages 
         (message, 
          context_contact_id,
          context_reception_id,
          context_contact_name,
          context_reception_name,
          taken_from_name, 
          taken_from_company, 
          taken_by_agent, 
          flags)
    VALUES 
         (@message, 
          @context_contact_id,
          @context_reception_id,
          @context_contact_name,
          @context_reception_name,
          @taken_from_name,
          @taken_from_company,
          @taken_by_agent, 
          @flags)
    RETURNING id;
    '''; //@created_at

  Map parameters = {'message'                : message,
                    'context_contact_id'     : messageContext.contactID,
                    'context_reception_id'   : messageContext.receptionID,
                    'context_contact_name'   : messageContext.contactName,
                    'context_reception_name' : messageContext.receptionName,
                    'taken_from_name'        : callee['name'],
                    'taken_from_company'     : callee['company'],
                    'taken_by_agent'         : takenByAgentID,
                    'flags'                  : JSON.encode(flags)
                    };

  return database.query(_pool, sql, parameters).then((rows) {
    Map data = {};
    if (rows.length == 1) {
      data = {'id': rows.first.id};
    }
    return data;
  });
}

/**
 * [sqlRecipients] is expected to be a string in SQL row format e.g. ('name'), ('othername).
 * an empty list is denoted by ()
 *
 */
Future<Map> addRecipientsToSendMessage(String sqlRecipients) {
  assert (sqlRecipients != "");

  String sql = '''
    INSERT INTO message_recipients (contact_id, contact_name, reception_id, reception_name, message_id, recipient_role)
    VALUES $sqlRecipients''';


  print (sql);
  return database.execute(_pool, sql).then((int rowsAffected) {
    return {'rowsAffected': rowsAffected};
  });
}

Future<Map> enqueue(Message message) {

  final String context = '${packageName}.enqueue';

  String sql = '''INSERT INTO message_queue (message_id) VALUES (${message.ID})''';

  return database.execute(_pool, sql).then((rowsAffected) {
    logger.debugContext('Enqueued message with ID ${message.ID} for sending.', context);
    return rowsAffected;
  }).catchError((error) {
    log(sql);
    throw error;
  });

}


Future<Map> populateQueue(Message message) {

  final String context = "messageserver.database.populateQueue";

  int id = message.ID;
  String sql = '''
INSERT INTO message_queue (message_id, endpoint_id, recipient_role)
SELECT msg.id AS message_id, addr.id AS endpoint_id, mrc.recipient_role as "role" FROM 
messages AS msg
  JOIN message_recipients   mrc  ON msg.id = message_id 
  JOIN reception_contacts   rc   ON mrc.contact_id = rc.contact_id AND mrc.reception_id = rc.reception_id AND rc.wants_messages
  JOIN messaging_end_points mep  ON rc.contact_id = mep.contact_id AND rc.reception_id = mrc.reception_id AND mep.enabled
  JOIN messaging_addresses  addr ON mep.address_id = addr.id
  WHERE message_id = $id''';

  return database.execute(_pool, sql).then((rowsAffected) {
    logger.debugContext("Inserted ${rowsAffected} in queue for message with ID: ${message.ID}", context);
    return rowsAffected;
  }).catchError((error) {
    log(sql);
    throw error;
  });

}

/**
 * [receptionContacts] is a list of strings like "contact_id@reception_id"
 */
Future<Map> getSendMessageContacts(List<String> receptionContacts) {
  assert(receptionContacts.isNotEmpty);
  String ContactList = receptionContacts
      .map((String raw) => raw.split('@'))
      .map((List<String> simpleDivide) {
          int contactId = int.parse(simpleDivide[0]);
          int receptionId = int.parse(simpleDivide[1]);
          return'($contactId, $receptionId)';
        })
      .join(','); //Transform ["1@2", "3@4"] into "(1,2),(3,4)"

  String sql = '''
    SELECT 
      mep.contact_id, 
      mep.reception_id, 
      mep.address_id, 
      mep.confidential, 
      mep.enabled AND rc.enabled AND c.enabled as enabled, 
      mep.priority,
      rc.wants_messages,
      ma.address,
      ma.address_type
    FROM messaging_end_points mep
      JOIN (VALUES $ContactList) alias(contact_id, reception_id) ON alias.contact_id = mep.contact_id AND alias.reception_id = mep.reception_id
      JOIN messaging_addresses ma ON mep.address_id = ma.id
      JOIN reception_contacts rc ON mep.contact_id = rc.contact_id AND mep.reception_id = rc.reception_id
      JOIN contacts c ON rc.contact_id = c.id;''';

  return database.query(_pool, sql).then((rows) {
    List contacts = new List();
    for(var row in rows) {
      Map contact =
        {'reception_id'    : row.reception_id,
         'contact_id'      : row.contact_id,
         'address_id'      : row.address_id,
         'confidential'    : row.confidential,
         'enabled'         : row.enabled,
         'priority'        : row.priority,
         'wants_messages'  : row.wants_messages};
      contacts.add(contact);
    }

    Map data = {'contacts': contacts};

    return data;
  }).catchError((error) {
    log(sql);
    throw error;
  });
}
