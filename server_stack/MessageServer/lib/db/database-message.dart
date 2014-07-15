part of messageserver.database;

abstract class Message {
  
  static const String className = '${libraryName}.Message';
  
  /**
   * 
   */
  static Future<List<Model.MessageHeader>> headers (int fromID, int limit){
    throw new StateError ('FIXME');
  }

  /**
   * 
   */
  static Future enqueue(Model.Message message) {
    assert (message.ID != Model.Message.noID);
    
    final String context = '${className}.enqueue';
    
    String sql = '''INSERT INTO message_queue (message_id) VALUES (${message.ID})''';

    return database.execute(_pool, sql).then((rowsAffected) {
      logger.debugContext('Enqueued message with ID ${message.ID} for sending $rowsAffected rows affected.', context);
      
      if (rowsAffected < 1) {
        throw new CreateFailed('Enqueue failed on id ${message.ID}');
      }
      
      return addRecipientsToSendMessage(message.sqlRecipients());
       
    }).catchError((error) {
      log(sql);
      throw error;
    });
  }

  /**
   * 
   */
  static Future<Map> list ({int fromID : Model.Message.noID, int limit : 100}){
    int limit = 100;
    String sql = '''
        SELECT
             message.id,
             message, 
             context_contact_id,
             context_reception_id,
             context_contact_name,
             context_reception_name,
             taken_from_name,
             taken_from_company,
             taken_from_phone,
             taken_from_cellphone,
             send_from      AS agent_address,
             flags, 
             created_at,
             taken_by_agent AS taken_by_agent_id,
             users.name     AS taken_by_agent_name,
             (SELECT count(*) FROM message_queue AS queue WHERE queue.message_id = message.id) AS pending_messages
        FROM messages message
             JOIN users on taken_by_agent = users.id
      ORDER BY 
           message.id    DESC
      LIMIT ${limit} 
    ''';

    return database.query(_pool, sql).then((rows) {
      List messages = new List();
      
      for(var row in rows) {
        
        DateTime createdAt = row.created_at;
        
        if (createdAt == null) {
          createdAt = new DateTime.fromMillisecondsSinceEpoch(0);
        }
                    
        Map message =
          {'id'                    : row.id,
           'message'               : row.message,
           'context'               : {'contact'   : 
                                       {'id'   : row.context_contact_id, 
                                        'name' : row.context_contact_name},
                                      'reception' : 
                                       {'id'   : row.context_reception_id, 
                                        'name' : row.context_reception_name}},
           'taken_by_agent'        : {'name'    : row.taken_by_agent_name, 
                                      'id'      : row.taken_by_agent_id, 
                                      'address' : row.agent_address},
           'caller'                : {'name'      : row.taken_from_name,
                                      'company'   : row.taken_from_company,
                                      'phone'     : row.taken_from_phone,
                                      'cellphone' : row.taken_from_cellphone},
           'flags'                 : JSON.decode(row.flags),
           'created_at'            : createdAt.millisecondsSinceEpoch,
           'pending_messages'      : row.pending_messages};
        messages.add(message);
      }

      return {'messages': messages};
    });
  }

  /**
   * Fetches the recipients for a message from the database.
   */
  static Future<Model.MessageRecipientList> recipients(Model.Message message) {
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
          message_id = ${message.ID};''';
    
    return database.query(_pool, sql).then((rows) {
      Model.MessageRecipientList recipientList = new Model.MessageRecipientList.empty(); 
    
      for(var row in rows) {
        
        print (recipientList.asMap);
        
        recipientList.add(new MessageRecipient.fromMap(
            {'contact'   : { 'id'   : row.contact_id, 
                             'name' : row.contact_name},
             'reception' : { 'id'   : row.reception_id,
                             'name' : row.reception_name}
          }, role : row.recipient_role));
      }
      return recipientList;
    });
  }
 
  /**
   *
   */
  static Future<Map> save(Model.Message message) {
    String sql = '''
      INSERT INTO messages 
           (message, 
            context_contact_id,
            context_reception_id,
            context_contact_name,
            context_reception_name,
            taken_from_name, 
            taken_from_company, 
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
            @taken_by_agent, 
            @flags)
      RETURNING id;
      '''; //@created_at

    Map parameters = {'message'                : message.body,
                      'context_contact_id'     : message.context.contactID,
                      'context_reception_id'   : message.context.receptionID,
                      'context_contact_name'   : message.context.contactName,
                      'context_reception_name' : message.context.receptionName,
                      'taken_from_name'        : message.caller['name'],
                      'taken_from_company'     : message.caller['company'],
                      'taken_by_agent'         : message.sender.ID,
                      'flags'                  : JSON.encode(message.flags)
                      };
    
    return database.query(_pool, sql, parameters).then((rows) {
      Map data = {};
      if (rows.length == 1) {
        data = {'id': rows.first.id};
      }
      return data;
    });
  }
  
  
  /**
   * Retrieves a single message from the database.
   */
  static Future<Map> get(int messageID) {
    String sql = '''
        SELECT
             message.id,
             message, 
             context_contact_id,
             context_reception_id,
             context_contact_name,
             context_reception_name,
             taken_from_name,
             taken_from_company,
             taken_from_phone,
             taken_from_cellphone,
             send_from      AS agent_address,
             flags, 
             created_at,
             taken_by_agent AS taken_by_agent_id,
             users.name     AS taken_by_agent_name,
             (SELECT count(*) FROM message_queue AS queue WHERE queue.message_id = message.id) AS pending_messages
        FROM messages message
             JOIN users on taken_by_agent = users.id
      WHERE    message.id = @messageID
      ORDER BY 
           message.id    DESC;''';

    Map parameters = {'messageID' : messageID};

    return database.query(_pool, sql, parameters).then((rows) {
      if (rows.isEmpty) {
        throw new NotFound('No message in database with ID $messageID');
      }
      
        var row = rows.first;
        
        DateTime createdAt = row.created_at;
        
        if (createdAt == null) {
          createdAt = new DateTime.fromMillisecondsSinceEpoch(0);
        }

        Map message =
          {'id'                    : row.id,
           'message'               : row.message,
           'context'               : {'contact'   : 
                                       {'id'   : row.context_contact_id, 
                                        'name' : row.context_contact_name},
                                      'reception' : 
                                       {'id'   : row.context_reception_id, 
                                        'name' : row.context_reception_name}},
           'taken_by_agent'        : {'name'    : row.taken_by_agent_name, 
                                      'id'      : row.taken_by_agent_id, 
                                      'address' : row.agent_address},
           'caller'                : {'name'      : row.taken_from_name,
                                      'company'   : row.taken_from_company,
                                      'phone'     : row.taken_from_phone,
                                      'cellphone' : row.taken_from_cellphone},
           'flags'                 : JSON.decode(row.flags),
           'created_at'            : createdAt,
           'pending_messages'      : row.pending_messages};

      return message;
    });
  }
  
  /**
   * [sqlRecipients] is expected to be a string in SQL row format e.g. ('name'), ('othername).
   * an empty list is denoted by ()
   * 
   */
  static Future<Map> addRecipientsToSendMessage(String sqlRecipients) {
    assert (sqlRecipients != ""); 
    
    String sql = '''
      INSERT INTO message_recipients (contact_id, contact_name, reception_id, reception_name, message_id, recipient_role)
      VALUES $sqlRecipients''';

    return database.execute(_pool, sql).then((int rowsAffected) {
      return {'rowsAffected': rowsAffected};
    });
  }

}