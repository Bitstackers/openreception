part of messageserver.database;

Future<Map> messageSingle(int messageID) {
  String sql = '''
    SELECT
         id, message, subject, to_contact_id, taken_from, taken_by_agent, urgent, created_at,
         (SELECT count(*) FROM message_queue WHERE message_id = message.id) AS pending_messages
    FROM message
    WHERE    id = $messageID 
    ORDER BY id DESC;''';

  Map parameters = {};

  return database.query(_pool, sql, parameters).then((rows) {
      var row = rows.first;
      
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

    return message;
  });
}
