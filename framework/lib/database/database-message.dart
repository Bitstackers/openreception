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
  static const String className = '${libraryName}.Message';

  static final Logger log = new Logger(className);

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
       message.id
     )
  ''';

  static const String sqlSentStatus = '''
  sent_status AS (
     SELECT 
        message.id AS message_id, count(mqh.id) > 0 AS sent
     FROM 
        message_queue_history mqh 
     RIGHT JOIN 
        messages message ON message.id = mqh.message_id
     GROUP BY 
       message.id
  )''';

  Connection _connection;

  Message(this._connection);

  /*
   /**
   *
   */
  static Future<List<Model.MessageHeader>> headers (int fromID, int limit){
    throw new StateError ('FIXME');
  }*/

  /**
   *
   */
  Future<Model.MessageQueueItem> enqueue(Model.Message message) {

    if (message.ID == Model.Message.noID) {
      return new Future.error(new ArgumentError.value(
          message.ID, 'message.ID', 'Message.ID cannot be noID'));
    }

    String sql ='''
  INSERT INTO 
    message_queue 
     (message_id, unhandled_endpoints) 
  VALUES 
     (@message_id, @unhandled_endpoints)
  RETURNING id''';

     Map parameters = {
       'message_id' : message.ID,
       'unhandled_endpoints' :
          JSON.encode(message.recipients.toList(growable: false))
     };

    return this._connection.query(sql, parameters).then((Iterable rows) {
      if (rows.length < 1) {
        return new Future.value(
            new Storage.SaveFailed('Enqueue failed on id ${message.ID}'));
      }

      log.finest('Enqueued message with ID ${message.ID} for sending. '
          'Queue id ${rows.first.id}');

      Model.MessageQueueItem queueItem = new Model.MessageQueueItem.empty()
        ..ID = rows.first.id
        ..messageID = message.ID;

      return queueItem;
    }).catchError((error, stackTrace) {
      log.severe(sql, error, stackTrace);
      throw error;
    });
  }

  /**
   *
   */
  Future<List<Model.Message>> list({Model.MessageFilter filter: null}) {
    if (filter == null) {
      filter = new Model.MessageFilter.empty();
    }

    final sqlMacro = 'WITH $sqlQueueStatus,$sqlSentStatus';

    String sql = '''
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
        FROM messages message
        JOIN users        ON taken_by_agent = users.id
        JOIN queue_status ON queue_status.message_id = message.id
        JOIN sent_status  ON sent_status.message_id = message.id
        ${filter.asSQL}
        ORDER BY 
           message.id DESC
        LIMIT ${filter.limitCount} 
    ''';

    return _connection
        .query(sql)
        .then((rows) => (rows as Iterable).map(_rowToMessage))
        .catchError((error, stackTrace) {
      log.severe('sql:$sql', error, stackTrace);
      return new Future.error(error, stackTrace);
    });
  }

  Future<Model.Message> update(Model.Message message) {
    log.finest('Updating message with ID ${message.ID}.');

    String sql = '''
    UPDATE messages
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
    WHERE id=${message.ID};''';

    Map parameters = {
      'message': message.body,
      'callId' : message.callId,
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

    return _connection
        .execute(sql, parameters)
        .then((int rowsAffected) =>
          rowsAffected == 1
            ? message
            : new Future.error(new StateError('Expected exactly one row to '
                'update, but counted $rowsAffected updates')))
        .catchError((error, stackTrace) {
      /// Log and forward.
      log.severe('sql:$sql :: parameters:$parameters');
      return new Future.error(error, stackTrace);
    });
  }

  /**
   *
   */
  Future<Model.Message> create(Model.Message message) {
    if (message.ID != Model.Message.noID) {
      return this.update(message);
    }

    log.finest('Creating new message.');

    String sql = '''
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
      RETURNING id, created_at;''';

    Map parameters = {
      'message': message.body,
      'recipients' : JSON.encode(message.recipients.toList(growable: false)),
      'callId' : message.callId,
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

    return _connection.query(sql, parameters).then(
        (Iterable rows) => rows.length == 1
            ? (message
      ..ID = rows.first.id
      ..createdAt = rows.first.created_at)
        : new Future.error(
                new Storage.ServerError('Failed to create new organization'))
            .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters');
      return new Future.error(error, stackTrace);
    }));
  }

  /**
   * Retrieves a single message from the database.
   */
  Future<Model.Message> get(int messageID) {
    final sqlMacro = 'WITH $sqlQueueStatus,$sqlSentStatus';

    String sql = '''
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
        FROM messages message
        JOIN users        ON taken_by_agent = users.id
        JOIN queue_status ON queue_status.message_id = message.id
        JOIN sent_status  ON sent_status.message_id = message.id
        WHERE    message.id = @messageID;''';

    Map parameters = {'messageID': messageID};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.isEmpty
            ? new Future.error(
                new Storage.NotFound('No message with ID $messageID'))
            : _rowToMessage(rows.first))
        .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe('sql:$sql :: parameters:$parameters');
      }

      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Please use either [update] or [create] instead.
   */
  @deprecated
  Future<Model.Message> save(Model.Message message) =>
      message.ID == Model.Message.noID ? create(message) : update(message);


  /**
   * Removes a single message from the database.
   */
  Future<Model.Message> remove(int messageID) {
    final sqlMacro = 'WITH $sqlQueueStatus,$sqlSentStatus';

    String sql = '''
    $sqlMacro,
    unused_message AS (
    SELECT id
    FROM messages message
    JOIN queue_status ON queue_status.message_id = message.id
    JOIN sent_status  ON sent_status.message_id = message.id
    WHERE    message.id = @messageID AND NOT enqueued AND NOT sent)

    DELETE FROM messages
    WHERE messages.id IN (SELECT id from unused_message)''';

    Map parameters = {'messageID': messageID};

    return _connection
        .execute(sql, parameters)
        .then((int rowsAffected) => rowsAffected != 1
            ? new Future.error(
                new Storage.NotFound
                  ('Cannot remove message with ID $messageID'))
            : true)
        .catchError((error, stackTrace) {

      log.severe('sql:$sql :: parameters:$parameters');
      return new Future.error(error, stackTrace);
    });
  }
}
