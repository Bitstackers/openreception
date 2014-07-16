part of messagedispatcher.database;

Future<List> messageQueueSingle() {

  final context = '${libraryName}.messageQueueSingle';

  int limit = 100;
  String sql = '''
   SELECT 
       mq.message_id,
       mq.recipient_role,
       mq.last_try,
       mq.tries,
       addr.address,
       addr.address_type
   FROM 
            message_queue mq
       JOIN messaging_addresses  addr ON mq.endpoint_id = addr.id

   ORDER BY
       mq.last_try DESC
   LIMIT ${limit} 
  ''';

  return database.query(_pool, sql).then((rows) {
    logger.debugContext(rows.length.toString(), context);

    List queue = new List();

    for (var row in rows) {

      queue.add({
        'message_id': row.message_id,
        'recipient_role': row.recipient_role,
        'address_type': row.address_type,
        'address': row.address,
        'last_try': row.last_try,
        'tries': row.tries
      });
    }

    return queue;
  });
}

abstract class MessageQueue {

  static final className = '${libraryName}.MessageQueue';

  /**
   * Removes a single queue entry from the database.
   */
  static Future remove(int queueID) {

    final context = className + ".remove";

    String sql = 'DELETE FROM message_queue WHERE id = ${queueID};';

    return database.execute(_pool, sql).then((rowsAffected) {
      logger.debugContext('Removed ${rowsAffected} message from queue.', context);
      return rowsAffected;
    }).catchError((error) {
      log(sql);
      throw error;
    });
  }

  static Future<List<Model.MessageEndpoint>> endpoints (int messageID) {
    final context = '${className}.endpoints';

    String sql = '''
    SELECT 
      mr.contact_name as name,
      mr.recipient_role as role, 
      ma.address as address,
      ma.address_type as type
    FROM
    message_queue mq
    JOIN
    messages msg ON mq.message_id = msg.id
    JOIN
    message_recipients mr ON mr.message_id = msg.id
    JOIN
    messaging_end_points mep ON mep.reception_id = mr.reception_id AND mep.contact_id = mr.contact_id
    JOIN
    messaging_addresses ma ON mep.address_id = ma.id
    WHERE mq.message_id = $messageID
    ''';

    return database.query(_pool, sql).then((rows) {
      logger.debugContext(rows.length.toString(), context);

      List<Model.MessageEndpoint> endpoints = new List<Model.MessageEndpoint>();

      for (var row in rows) {
        endpoints.add(new Model.MessageEndpoint.fromMap({
          'name'    : row.name,
          'role'    : row.role,
          'address' : row.address,
          'type'    : row.type,
        }));
      }

      return endpoints;
    });
  }
  
  
}
