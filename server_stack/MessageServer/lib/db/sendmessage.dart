part of messageserver.database;

Future<Map> createSendMessage(String message, String subject, int toContactId, String takenFrom, int takeByAgent, bool urgent, DateTime createdAt) {
  String sql = '''
    INSERT INTO message_queue (message, subject, to_contact_id, taken_from, taken_by_agent, urgent, created_at)
    VALUES (@message, @subject, @to_contact_id, @taken_from, @taken_by_agent, @urgent, timestamp'$createdAt')
    RETURNING id;
    '''; //@created_at

  Map parameters = {'message'        : message,
                    'subject'        : subject,
                    'to_contact_id'  : toContactId,
                    'taken_from'     : takenFrom,
                    'taken_by_agent' : takeByAgent,
                    'urgent'         : urgent
                    //'created_at'     : createdAt.toString()
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
 * [recipients] should be in the format [{contact_id, reception_id, message_id, recipient_role}]
 */
Future<Map> addRecipientsToSendMessage(List<Map> recipients) {
  String sqlRecipients = recipients.map((Map recipient) => '(${recipient['contact_id']}, ${recipient['reception_id']},${recipient['message_id']},${recipient['recipient_role']}').join(',');
  
  String sql = '''
    INSERT INTO receptions (contact_id, reception_id, message_id, recipient_role)
    VALUES $sqlRecipients
  ''';
  
  return database.execute(_pool, sql).then((int rowsAffected) {
    return {'rowsAffected': rowsAffected};
  });
}
