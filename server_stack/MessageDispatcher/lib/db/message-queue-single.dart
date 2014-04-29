part of messagedispatcher.database;

Future<List> messageQueueSingle() {

  final context = packageName + ".messageQueueSingle";

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

  static final ClassName = '${packageName}.MessageQueue';

  /**
   * Removes a single queue entry from the database.
   */
  static Future remove(int queueID) {

    final context = ClassName + ".remove";

    String sql = 'DELETE FROM message_queue WHERE id = ${queueID};';

    return database.execute(_pool, sql).then((rowsAffected) {
      logger.debugContext('Removed ${rowsAffected} message from queue.', context);
      return rowsAffected;
    }).catchError((error) {
      log(sql);
      throw error;
    });

  }

}
