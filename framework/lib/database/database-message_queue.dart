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
  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  MessageQueue(this._connection);

  /**
   * Archive a single message queue entry.
   */
  Future archive(Model.MessageQueueItem queueItem) async {
    final String sql = '''
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
  message_queue_history
  (message_id, enqueued_at, handled_endpoints, last_try, tries)
(SELECT
   message_id, enqueued_at, handled_endpoints, last_try, tries
 FROM moved_rows)''';

    try {
      final int rowsAffected = await _connection.execute(sql);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No queue item with id: ${queueItem.ID}}');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * List all queue entries.
   */
  Future<List<Model.MessageQueueItem>> list(
      {int limit: 100, int maxTries: 10}) async {
    final String sql = '''
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

    final Map parameters = {'maxTries': maxTries, 'limit': limit};

    try {
      final rows = await _connection.query(sql, parameters);

      final List<Model.MessageQueueItem> queue = [];

      for (var row in rows) {
        Iterable<Model.MessageRecipient> unhandled_recipients =
            (row.unhandled_endpoints as Iterable)
                .map(Model.MessageRecipient.decode);

        Iterable<Model.MessageRecipient> handled_recipients =
            (row.handled_endpoints as Iterable)
                .map(Model.MessageRecipient.decode);

        queue.add(new Model.MessageQueueItem.empty()
          ..ID = row.id
          ..messageID = row.message_id
          ..handledRecipients = handled_recipients
          ..unhandledRecipients = unhandled_recipients
          ..tries = row.tries
          ..lastTry = row.last_try);
      }

      return queue;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve a single queue entry.
   */
  Future<Model.MessageQueueItem> get(int entryId) async {
    final String sql = '''
SELECT
  mq.id,
  mq.message_id,
  mq.unhandled_endpoints,
  mq.last_try,
  mq.tries
FROM
  message_queue mq
WHERE
  mq.id = $entryId''';

    try {
      Iterable rows = await _connection.query(sql);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No queue entry with id: $entryId');
      }

      var row = rows.first;

      return new Model.MessageQueueItem.fromMap({
        'id': row.id,
        'message_id': row.message_id,
        'unhandled_endpoints': row.unhandled_endpoints,
        'tries': row.tries,
        'last_try': row.last_try
      });
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Removes a single queue entry from the database.
   */
  Future remove(int entryId) async {
    final String sql = '''
DELETE FROM
  message_queue
WHERE
  id = ${entryId}''';

    try {
      final int rowsAffected = await _connection.execute(sql);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No queue entry with id: $entryId');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Updates a single queue entry in the database.
   */
  Future<Model.MessageQueueItem> save(Model.MessageQueueItem queueItem) async {
    /// We have to serialize the ID's of the contact along with the endpoint ID
    /// to avoid losing the name of the endpoint.

    final List<Map> unhandled_endpoints = queueItem.unhandledRecipients
        .map((Model.MessageRecipient r) => r.asMap)
        .toList(growable: false);

    final List<Map> handled_endpoints = queueItem.handledRecipients
        .map((Model.MessageRecipient r) => r.asMap)
        .toList(growable: false);

    final String sql = '''
UPDATE
  message_queue
SET
  last_try = NOW(),
  unhandled_endpoints = @unhandledEndpoints,
  handled_endpoints = @handledEndpoints,
  tries = @tries
WHERE
  id = @id''';

    final Map parameters = {
      'id': queueItem.ID,
      'tries': queueItem.tries,
      'handledEndpoints': JSON.encode(handled_endpoints),
      'unhandledEndpoints': JSON.encode(unhandled_endpoints),
    };

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('Queue entry not updated');
      }

      return queueItem;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
