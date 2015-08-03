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
  static const String SQL_MACROS = '''
  WITH queue_status AS (
     SELECT 
        message.id AS message_id, count(mq.id) > 0 AS enqueued
     FROM 
        message_queue mq 
     RIGHT JOIN 
        messages message ON message.id = mq.message_id
     GROUP BY 
       message.id
     ),
  sent_status AS (
     SELECT 
        message.id AS message_id, count(mqh.id) > 0 AS sent
     FROM 
        message_queue_history mqh 
     RIGHT JOIN 
        messages message ON message.id = mqh.message_id
     GROUP BY 
       message.id
  ),
  recipients_json_list AS (
  SELECT
   messages.id AS message_id,
  (SELECT array_agg(row_to_json(tmp))
   FROM (
    SELECT contact_id, reception_id, contact_name, reception_name, recipient_role
    FROM message_recipients
    WHERE messages.id = message_recipients.message_id
   ) tmp
  ) AS recipients
  FROM 
    messages
  GROUP BY messages.id),
  
  recipients_with_endpoints_json_list AS (
  SELECT
   messages.id AS message_id,
  (SELECT array_to_json (array_agg(row_to_json(recpient_row)))
   FROM (
    SELECT contact_id, reception_id, contact_name, reception_name, recipient_role,
      (SELECT array_to_json (array_agg(row_to_json(endpoint_row)))
       FROM (
       SELECT address_type AS type, address
       FROM messaging_end_points
       WHERE messaging_end_points.contact_id = message_recipients.contact_id AND 
             messaging_end_points.reception_id = message_recipients.reception_id
       ) endpoint_row
      ) AS endpoints
      FROM message_recipients
      WHERE messages.id = message_recipients.message_id
     ) recpient_row
    ) AS recipients
  FROM 
    messages
  GROUP BY messages.id
  )
''';

  Connection _database;

  Message (this._database);

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
  Future<Model.MessageQueueItem> enqueue (Model.Message message) {

    if (message.ID == Model.Message.noID) {
      return new Future.error(new ArgumentError.value(message.ID, 'message.ID', 'Message.ID cannot be noID'));
    }

    String sql = '''INSERT INTO message_queue (message_id) VALUES (${message.ID}) RETURNING id''';


    return this._database.query(sql).then((Iterable rows) {
      if (rows.length < 1) {
        return new Future.value
          (new Storage.SaveFailed('Enqueue failed on id ${message.ID}'));
      }

      log.finest('Enqueued message with ID ${message.ID} for sending. '
                 'Queue id ${rows.first.id}');

      Model.MessageQueueItem queueItem =
        new Model.MessageQueueItem()
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
  Future<List<Model.Message>> list ({Model.MessageFilter filter : null}){
    if (filter == null) {
      filter = new Model.MessageFilter.empty();
    }

    String sql = '''
        ${SQL_MACROS}
        SELECT
             message.id,
             message, 
             recipients_with_endpoints_json_list.recipients as json_recipients,
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
        JOIN recipients_with_endpoints_json_list ON recipients_with_endpoints_json_list.message_id = message.id
        ${filter.asSQL}
        ORDER BY 
           message.id DESC
        LIMIT ${filter.limitCount} 
    ''';


    Model.Message rowToMessage (var row) =>
      new Model.Message.fromMap(
        {'id'                    : row.id,
                   'message'               : row.message,
                   'recipients'            : row.json_recipients != null ?row.json_recipients : [],
                   'context'               : {'contact'   :
                                               {'id'   : row.context_contact_id,
                                                'name' : row.context_contact_name},
                                              'reception' :
                                               {'id'   : row.context_reception_id,
                                                'name' : row.context_reception_name}},
                   'taken_by_agent'        : {'name'    : row.taken_by_agent_name,
                                              'id'      : row.taken_by_agent_id,
                                              'address' : row.agent_address},
                   'caller'                : {'name'           : row.taken_from_name,
                                              'company'        : row.taken_from_company,
                                              'phone'          : row.taken_from_phone,
                                              'cellphone'      : row.taken_from_cellphone,
                                              'localExtension' : row.taken_from_localexten},
                   'flags'                 : row.flags,
                   'enqueued'              : row.enqueued,
                   'created_at'            : Util.dateTimeToUnixTimestamp(row.created_at),
                   'sent'                  : row.sent}
  );

    return this._database.query(sql).then((Iterable rows) =>
      rows.map(rowToMessage));
  }

  /**
   * Fetches the recipients for a message from the database.
   */
  static Future<Model.MessageRecipientList> recipients(int messageID, Connection database) {
    String sql = '''
       SELECT 
          contact_id, 
          contact_name, 
          reception_id, 
          reception_name, 
          recipient_role 
       FROM 
          message_recipients 
       WHERE 
          message_id = ${messageID};''';

    return database.query(sql).then((rows) {
      Model.MessageRecipientList recipientList = new Model.MessageRecipientList.empty();

      for(var row in rows) {
        recipientList.add(new Model.MessageRecipient.fromMap(
            {'contact'   : { 'id'   : row.contact_id,
                             'name' : row.contact_name},
             'reception' : { 'id'   : row.reception_id,
                             'name' : row.reception_name}
          }, role : row.recipient_role));
      }
      return recipientList;
    });
  }

  Future<Model.Message> update (Model.Message message) {
    log.finest('Updating message with ID ${message.ID}.');

    String sql = '''
    UPDATE messages
       SET 
         message                 = @message,
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

    Map parameters = {'message'                : message.body,
                      'context_contact_id'     : message.context.contactID,
                      'context_reception_id'   : message.context.receptionID,
                      'context_contact_name'   : message.context.contactName,
                      'context_reception_name' : message.context.receptionName,
                      'taken_from_name'        : message.caller.name,
                      'taken_from_company'     : message.caller.company,
                      'taken_from_phone'       : message.caller.phone,
                      'taken_from_cellphone'   : message.caller.cellphone,
                      'taken_from_localexten'  : message.caller.localExtension,
                      'flags'                  : JSON.encode(message.flags)
                      };

    return this._database.query(sql, parameters).then((rows) {
      if (rows.length == 1) {
        message.ID = rows.first.id;
      }
      return message;
    });
  }

  /**
   *
   */
  Future<Model.Message> create (Model.Message message) {
    if (message.ID != Model.Message.noID) {
      return this.update(message);
    }

    log.finest('Creating new message.');


    String sql = '''
      INSERT INTO messages 
           (message, 
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
      RETURNING id;
      '''; //@created_at

    Map parameters = {'message'                : message.body,
                      'context_contact_id'     : message.context.contactID,
                      'context_reception_id'   : message.context.receptionID,
                      'context_contact_name'   : message.context.contactName,
                      'context_reception_name' : message.context.receptionName,
                      'taken_from_name'        : message.caller.name,
                      'taken_from_company'     : message.caller.company,
                      'taken_from_phone'       : message.caller.phone,
                      'taken_from_cellphone'   : message.caller.cellphone,
                      'taken_from_localexten'  : message.caller.localExtension,
                      'taken_by_agent'         : message.sender.ID,
                      'flags'                  : JSON.encode(message.flags)
                      };

    return this._database.query(sql, parameters).then((rows) {
      if (rows.length == 1) {
        message.ID = rows.first.id;
      }

      return this.addRecipientsToSendMessage(message).then((_) => message);
    });
  }


  /**
   * Retrieves a single message from the database.
   */
  Future<Model.Message> get (int messageID) {
    String sql = '''
        ${SQL_MACROS}
        SELECT
             message.id,
             message, 
             recipients_with_endpoints_json_list.recipients as json_recipients,
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
        JOIN recipients_with_endpoints_json_list ON recipients_with_endpoints_json_list.message_id = message.id
        WHERE    message.id = @messageID;''';

    Map parameters = {'messageID' : messageID};

    return this._database.query(sql, parameters).then((rows) {
      if (rows.isEmpty) {
        throw new Storage.NotFound('No message in database with ID $messageID');
      }

        var row = rows.first;

        return new Model.Message.fromMap(
          {'id'                    : row.id,
           'message'               : row.message,
           'recipients'            : row.json_recipients != null ?row.json_recipients : [],
           'context'               : {'contact'   :
                                       {'id'   : row.context_contact_id,
                                        'name' : row.context_contact_name},
                                      'reception' :
                                       {'id'   : row.context_reception_id,
                                        'name' : row.context_reception_name}},
           'taken_by_agent'        : {'name'    : row.taken_by_agent_name,
                                      'id'      : row.taken_by_agent_id,
                                      'address' : row.agent_address},
           'caller'                : {'name'           : row.taken_from_name,
                                      'company'        : row.taken_from_company,
                                      'phone'          : row.taken_from_phone,
                                      'cellphone'      : row.taken_from_cellphone,
                                      'localExtension' : row.taken_from_localexten},
           'flags'                 : row.flags,
           'enqueued'              : row.enqueued,
           'created_at'            : Util.dateTimeToUnixTimestamp(row.created_at),
           'sent'                  : row.sent});

    });
  }

  /**
   * [sqlRecipients] is expected to be a string in SQL row format e.g. ('name'), ('othername).
   * an empty list is denoted by ()
   *
   */
  Future<Map> addRecipientsToSendMessage(Model.Message message) {
    assert (message.sqlRecipients != "");

    String sql = '''
    WITH existing_rows AS (
      DELETE 
        FROM 
          message_recipients 
        WHERE 
          message_id = ${message.ID} 
        RETURNING
          contact_id, 
          contact_name, 
          reception_id, 
          reception_name, 
          message_id, 
          recipient_role
    )
    INSERT 
       INTO 
          message_recipients 
             (contact_id, contact_name, reception_id, reception_name, message_id, recipient_role)
          SELECT * 
          FROM 
             existing_rows 
            INTERSECT VALUES ${message.sqlRecipients()} UNION VALUES ${message.sqlRecipients()};''';

    return this._database.execute(sql).then((int rowsAffected) {
      return {'rowsAffected': rowsAffected};
    });
  }

  Future<Model.Message> save (Model.Message message) =>
      message.ID == Model.Message.noID
      ? create(message)
      : update(message);
}