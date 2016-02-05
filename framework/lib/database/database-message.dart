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

class Message implements Storage.Message {
  /// WITH expressions used for harvesting various message
  /// status information and dereferencing recipient endpoints.
  static const String sqlQueueStatus = '''
queue_status AS (
  SELECT
    message.id AS message_id, count(mq.id) > 0 AS enqueued
  FROM
    message_queue mq
  RIGHT JOIN
    messages message ON message.id = mq.message_id
  GROUP BY
    message.id)''';

  static const String sqlSentStatus = '''
sent_status AS (
  SELECT
    message.id AS message_id, count(mqh.id) > 0 AS sent
  FROM
    message_queue_history mqh
  RIGHT JOIN
    messages message ON message.id = mqh.message_id
  GROUP BY
    message.id)''';

  /// Database connection.
  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  Message(this._connection);

  /**
   *
   */
  static Future<List<Model.MessageHeader>> headers(int fromID, int limit) {
    throw new StateError('FIXME');
  }

  /**
   *
   */
  Future<Model.MessageQueueItem> enqueue(Model.Message message) async {
    if (message.ID == Model.Message.noID) {
      throw new ArgumentError.value(
          message.ID, 'message.ID', 'Message.ID cannot be noID');
    }

    final String sql = '''
INSERT INTO
  message_queue
    (message_id, unhandled_endpoints)
VALUES
    (@message_id, @unhandled_endpoints)
RETURNING
  id''';

    final Map parameters = {
      'message_id': message.ID,
      'unhandled_endpoints':
          JSON.encode(message.recipients.toList(growable: false))
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('Enqueue failed on id ${message.ID}');
      }

      Model.MessageQueueItem queueItem = new Model.MessageQueueItem.empty()
        ..ID = rows.first.id
        ..messageID = message.ID;
      return queueItem;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<List<Model.Message>> list({Model.MessageFilter filter: null}) async {
    if (filter == null) {
      filter = new Model.MessageFilter.empty();
    }

    final sqlMacro = 'WITH $sqlQueueStatus,$sqlSentStatus';

    final String sql = '''
$sqlMacro
SELECT
  message.id,
  message,
  call_id,
  recipients,
  context_contact_id,
  context_reception_id,
  context_contact_name,
  context_reception_name,
  taken_from_name,
  taken_from_company,
  taken_from_phone,
  taken_from_cellphone,
  taken_from_localexten,
  send_from      AS agent_address,
  flags,
  created_at,
  taken_by_agent AS taken_by_agent_id,
  users.name     AS taken_by_agent_name,
  enqueued,
  sent
FROM
  messages message
JOIN
  users
ON
  taken_by_agent = users.id
JOIN
  queue_status
ON
  queue_status.message_id = message.id
JOIN
  sent_status
ON
  sent_status.message_id = message.id
${filter.asSQL}
ORDER BY
  message.id DESC
LIMIT
  ${filter.limitCount}''';

    try {
      final Iterable<PG.Row> rows = await _connection.query(sql);
      return rows.map(_rowToMessage);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.Message> update(Model.Message message) async {
    final String sql = '''
UPDATE
  messages
SET
  message                 = @message,
  recipients              = @recipients,
  call_id                 = @callId,
  context_contact_id      = @context_contact_id,
  context_reception_id    = @context_reception_id,
  context_contact_name    = @context_contact_name,
  context_reception_name  = @context_reception_name,
  taken_from_name         = @taken_from_name,
  taken_from_company      = @taken_from_company,
  taken_from_phone        = @taken_from_phone,
  taken_from_localexten   = @taken_from_localexten,
  taken_from_cellphone    = @taken_from_cellphone,
  flags                   = @flags
WHERE
  id = ${message.ID}''';

    Map parameters = {
      'message': message.body,
      'callId': message.callId,
      'context_contact_id': message.context.contactID,
      'context_reception_id': message.context.receptionID,
      'context_contact_name': message.context.contactName,
      'context_reception_name': message.context.receptionName,
      'recipients': JSON.encode(message.recipients.toList(growable: false)),
      'taken_from_name': message.callerInfo.name,
      'taken_from_company': message.callerInfo.company,
      'taken_from_phone': message.callerInfo.phone,
      'taken_from_cellphone': message.callerInfo.cellPhone,
      'taken_from_localexten': message.callerInfo.localExtension,
      'flags': JSON.encode(message.flag)
    };

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('Message not updated');
      }

      return message;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.Message> create(Model.Message message) async {
    final String sql = '''
INSERT INTO messages
 (message,
  recipients,
  call_id,
  context_contact_id,
  context_reception_id,
  context_contact_name,
  context_reception_name,
  taken_from_name,
  taken_from_company,
  taken_from_phone,
  taken_from_cellphone,
  taken_from_localexten,
  taken_by_agent,
  flags)
VALUES
 (@message,
  @recipients,
  @callId,
  @context_contact_id,
  @context_reception_id,
  @context_contact_name,
  @context_reception_name,
  @taken_from_name,
  @taken_from_company,
  @taken_from_phone,
  @taken_from_cellphone,
  @taken_from_localexten,
  @taken_by_agent,
  @flags)
RETURNING
  id,
  created_at''';

    final Map parameters = {
      'message': message.body,
      'recipients': JSON.encode(message.recipients.toList(growable: false)),
      'callId': message.callId,
      'context_contact_id': message.context.contactID,
      'context_reception_id': message.context.receptionID,
      'context_contact_name': message.context.contactName,
      'context_reception_name': message.context.receptionName,
      'taken_from_name': message.callerInfo.name,
      'taken_from_company': message.callerInfo.company,
      'taken_from_phone': message.callerInfo.phone,
      'taken_from_cellphone': message.callerInfo.cellPhone,
      'taken_from_localexten': message.callerInfo.localExtension,
      'taken_by_agent': message.senderId,
      'flags': JSON.encode(message.flag)
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('Message not created');
      }

      message
        ..ID = rows.first.id
        ..createdAt = rows.first.created_at;
      return message;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieves a single message from the database.
   */
  Future<Model.Message> get(int messageId) async {
    final sqlMacro = 'WITH $sqlQueueStatus,$sqlSentStatus';

    final String sql = '''
$sqlMacro
SELECT
  message.id,
  message,
  recipients,
  call_id,
  context_contact_id,
  context_reception_id,
  context_contact_name,
  context_reception_name,
  taken_from_name,
  taken_from_company,
  taken_from_phone,
  taken_from_cellphone,
  taken_from_localexten,
  send_from      AS agent_address,
  flags,
  created_at,
  taken_by_agent AS taken_by_agent_id,
  users.name     AS taken_by_agent_name,
  enqueued,
  sent
FROM
  messages message
JOIN
  users
ON
  taken_by_agent = users.id
JOIN
  queue_status
ON
  queue_status.message_id = message.id
JOIN
  sent_status
ON
  sent_status.message_id = message.id
WHERE
  message.id = @messageID''';

    final Map parameters = {'messageID': messageId};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No message with id: $messageId');
      }

      return _rowToMessage(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Removes a single message from the database.
   */
  Future remove(int messageId) async {
    final String sqlMacro = 'WITH $sqlQueueStatus,$sqlSentStatus';

    String sql = '''
$sqlMacro,
unused_message AS (
  SELECT
    id
  FROM
    messages message
  JOIN
    queue_status
  ON
    queue_status.message_id = message.id
  JOIN
    sent_status
  ON
    sent_status.message_id = message.id
  WHERE
    message.id = @messageID
  AND
    NOT enqueued
  AND
    NOT sent)

DELETE FROM
  messages
WHERE
  messages.id
IN
  (SELECT id from unused_message)''';

    Map parameters = {'messageID': messageId};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No message with id: $messageId');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
