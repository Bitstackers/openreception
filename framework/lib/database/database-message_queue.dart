/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.database;

class MessageQueue implements Storage.MessageQueue {

  static const String className = '$libraryName.MessageQueue';

  static final Logger log = new Logger(className);

  Connection _connection = null;

  MessageQueue(this._connection);

  Future archive(Model.MessageQueueItem queueItem) {

    String sql = '''
  WITH moved_rows AS (
      DELETE FROM 
         message_queue mq
      WHERE 
         id = ${queueItem.ID}
      RETURNING 
         mq.message_id, 
         mq.enqueued_at, 
         mq.last_try, 
         mq.tries
  )
  INSERT INTO 
    message_queue_history (
        message_id,
        enqueued_at,
        last_try,
        tries) 
    (SELECT 
       message_id, 
       enqueued_at, 
       last_try, 
       tries 
     FROM moved_rows); ''';

    return this._connection.execute(sql).then((rows) {
      log.finest('Archived message queue entry.');
    });
  }

  Future<List<Model.MessageQueueItem>> list({int limit: 100, int maxTries : 10}) {

    String sql = '''
   SELECT
       mq.id,
       mq.message_id,
       mq.unhandled_endpoints,
       mq.last_try,
       mq.tries
   FROM 
       message_queue mq
   WHERE 
       mq.tries <= $maxTries
   ORDER BY
       mq.last_try DESC,
       mq.message_id DESC
   LIMIT ${limit} 
  ''';

    return this._connection.query(sql).then((rows) {
      log.finest('Returned ${rows.length} queued messages (limit $limit).');

      List<Model.MessageQueueItem> queue = [];

      for (var row in rows) {

        queue.add(new Model.MessageQueueItem.fromMap({
          'id'                 : row.id,
          'message_id'         : row.message_id,
          'unhandled_endpoints': row.unhandled_endpoints,
          'tries'              : row.tries,
          'last_try'           : row.last_try
        }));
      }

      return queue;
    });
  }

  Future<Model.MessageQueueItem> get(int queueID) {

    String sql = '''
   SELECT 
       mq.id,
       mq.message_id,
       mq.unhandled_endpoints,
       mq.last_try,
       mq.tries
   FROM 
      message_queue mq
  WHERE
      mq.id = queueID''';

    return this._connection.query(sql).then((rows) {

      var row = rows.first;

      return new Model.MessageQueueItem.fromMap({
        'id'                 : row.id,
        'message_id'         : row.message_id,
        'unhandled_endpoints': row.unhandled_endpoints,
        'tries'              : row.tries,
        'last_try'           : row.last_try
      });
    });
  }

  /**
   * Removes a single queue entry from the database.
   */
  Future remove(int queueID) {

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
   * Updates a single queue entry in the database.
   */
  Future<Model.MessageQueueItem> save(Model.MessageQueueItem queueItem) {

    /// We have to serialize the ID's of the contact along with the endpoint ID
    /// to avoid losing the name of the endpoint.

    List<Map> unhandled_endpoints =
        queueItem.unhandledRecipients.map((Model.MessageRecipient r) =>
            r.asMap).toList();

    List<Map> handled_endpoints =
        queueItem.handledRecipients.map((Model.MessageRecipient r) =>
            r.asMap).toList();

    final String sql = '''
    UPDATE message_queue
       SET last_try=NOW(), 
       unhandled_endpoints='${unhandled_endpoints}',
       handled_endpoints='${handled_endpoints}',
       tries=${queueItem.tries}
    WHERE id=${queueItem.ID};''';

    return this._connection.execute(sql).then((_) => queueItem);
  }

  /**
   * Returns a list of endpoints associated with the message with id [messageID].
   */
  Future<List<Model.MessageEndpoint>> endpoints(int messageID) {
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
