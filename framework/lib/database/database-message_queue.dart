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

  /**
   * Archive a single message queue entry.
   */
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
         mq.handled_endpoints,
         mq.last_try, 
         mq.tries
  )
  INSERT INTO 
    message_queue_history (
        message_id,
        enqueued_at,
        handled_endpoints,
        last_try,
        tries) 
    (SELECT 
       message_id, 
       enqueued_at,
       handled_endpoints,
       last_try, 
       tries 
     FROM moved_rows); ''';

    return this._connection.execute(sql).then((rows) {
      log.finest('Archived message queue entry.');
    }).catchError((error, stackTrace) {
      log.severe('sql:$sql', error, stackTrace);
    });
  }

  /**
   * List all queue entries.
   */
  Future<List<Model.MessageQueueItem>> list({int limit: 100, int maxTries : 10}) {

    String sql = '''
   SELECT
       mq.id,
       mq.message_id,
       mq.unhandled_endpoints,
       mq.handled_endpoints,
       mq.last_try,
       mq.tries
   FROM 
       message_queue mq
   WHERE 
       mq.tries <= @maxTries
   ORDER BY
       mq.last_try DESC,
       mq.tries ASC
   LIMIT @limit
  ''';

  final Map parameters = {
    'maxTries' : maxTries,
    'limit' : limit
  };

    return this._connection.query(sql, parameters).then((rows) {
      log.finest('Returned ${rows.length} queued messages (limit $limit).');

      List<Model.MessageQueueItem> queue = [];

      for (var row in rows) {

        Iterable<Model.MessageRecipient> unhandled_recipients =
            (row.unhandled_endpoints as Iterable).map
            (Model.MessageRecipient.decode);

        Iterable<Model.MessageRecipient> handled_recipients =
            (row.handled_endpoints as Iterable).map
            (Model.MessageRecipient.decode);

        queue.add(new Model.MessageQueueItem.empty()
          ..ID = row.id
          ..messageID =  row.message_id
          ..handledRecipients = handled_recipients
          ..unhandledRecipients= unhandled_recipients
          ..tries = row.tries
          ..lastTry =  row.last_try);
      }

      return queue;
    }).catchError((error, stackTrace) {
      log.severe('sql:$sql \nparameters:$parameters', error, stackTrace);
    });
  }

  /**
   * Retrieve a single queue entry.
   */
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
      mq.id = $queueID''';

    return this._connection.query(sql).then((rows) {

      var row = rows.first;

      return new Model.MessageQueueItem.fromMap({
        'id'                 : row.id,
        'message_id'         : row.message_id,
        'unhandled_endpoints': row.unhandled_endpoints,
        'tries'              : row.tries,
        'last_try'           : row.last_try
      });
    }).catchError((error, stackTrace) {
      log.severe('sql:$sql', error, stackTrace);
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
            r.asMap).toList(growable: false);

    List<Map> handled_endpoints =
        queueItem.handledRecipients.map((Model.MessageRecipient r) =>
            r.asMap).toList(growable: false);

    final String sql = '''
    UPDATE message_queue
       SET last_try=NOW(), 
       unhandled_endpoints=@unhandledEndpoints,
       handled_endpoints=@handledEndpoints,
       tries=@tries
    WHERE id=@id''';

    final Map parameters = {
      'id' : queueItem.ID,
      'tries' : queueItem.tries,
      'handledEndpoints' : JSON.encode(handled_endpoints),
      'unhandledEndpoints' : JSON.encode(unhandled_endpoints),
    };

    return this._connection.execute(sql, parameters)
        .then((rowCount) =>
            rowCount == 0
            ? throw new Storage.NotFound()
            : queueItem)
            .catchError((error, stackTrace) {
      log.severe('sql:$sql \nparameters:$parameters', error, stackTrace);
    });
  }
}
