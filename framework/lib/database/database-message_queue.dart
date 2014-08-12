part of openreception.database;

class MessageQueue implements Storage.MessageQueue {

  static const String className = '$libraryName.MessageQueue';

  static final Logger log = new Logger(className);

  Connection _connection = null;

  MessageQueue(this._connection);

  Future<List> list({int limit: 100}) {

    final context = '${className}.list';

    String sql = '''
   SELECT 
       mq.id,
       mq.message_id,
       msg.context_contact_name,
       mq.last_try,
       mq.tries

   FROM message_queue          mq
   JOIN messages msg ON mq.message_id = msg.id

   ORDER BY
       mq.last_try DESC,
       msg.created_at DESC
   LIMIT ${limit} 
  ''';

    return this._connection.query(sql).then((rows) {
      log.finest('Returned ${rows.length} queued messages (limit $limit).');

      List queue = new List();

      for (var row in rows) {

        queue.add({
          'queue_id': row.id,
          'message_id': row.message_id,
          'context_contact_name': row.context_contact_name,
          'last_try': row.last_try,
          'tries': row.tries
        });
      }

      return queue;
    });
  }

  Future get(int queueID) {

    final context = '$className.get';

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
  WHERE
      mq.id = queueID''';

    return this._connection.query(sql).then((rows) {

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

      return queue.first;
    });
  }

  /**
   * Removes a single queue entry from the database.
   */
  Future remove(int queueID) {

    final context = className + ".remove";

    String sql = 'DELETE FROM message_queue WHERE id = ${queueID};';

    return this._connection.execute(sql).then((rowsAffected) {
      log.finest('Removed ${rowsAffected} message from queue.');
      return rowsAffected;
    }).catchError((error) {
      log.severe(sql);
      throw error;
    });
  }

  /**
   * Removes a single queue entry from the database.
   */
  Future<Model.MessageQueueItem> save(Model.MessageQueueItem queueItem) {

    final context = className + ".save";

    return new Future(() => throw new StateError('Not implemented'));
  }

  Future<List<Model.MessageEndpoint>> endpoints(int messageID) {
    final context = '${className}.endpoints';

    String sql = '''
    SELECT 
      mr.contact_name as name,
      mr.recipient_role as role, 
      mep.address as address,
      mep.address_type as type
    FROM message_queue mq
      JOIN messages msg ON mq.message_id = msg.id
      JOIN message_recipients mr ON mr.message_id = msg.id
      JOIN messaging_end_points mep ON mep.reception_id = mr.reception_id AND 
                                       mep.contact_id = mr.contact_id
    WHERE mq.message_id = $messageID
    ''';

    return this._connection.query(sql).then((rows) {
      log.finest(rows.length.toString());

      List<Model.MessageEndpoint> endpoints = new List<Model.MessageEndpoint>();

      for (var row in rows) {
        endpoints.add(new Model.MessageEndpoint.fromMap({
          'name': row.name,
          'role': row.role,
          'address': row.address,
          'type': row.type,
        }));
      }

      return endpoints;
    });
  }
}
