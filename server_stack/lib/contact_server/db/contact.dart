part of contactserver.database;

abstract class Contact {

  static final Logger log = new Logger('$libraryName.Contact');

  static Future<Model.BaseContact> baseContact(int contactID) {
    String sql = '''
    SELECT id, full_name, contact_type, enabled
    FROM contacts
    WHERE id = @contactID ''';

    Map parameters = {'contactID': contactID};

    return connection.query(sql, parameters).then((Iterable rows) {
      if (rows.isEmpty) {
        throw new Storage.NotFound('No contact found with ID $contactID');
      }

      return _rowToBaseContact(rows.first);
    });
  }

  static Future<List<Model.BaseContact>> baseContactList() {
    String sql = '''
    SELECT id, full_name, contact_type, enabled
    FROM contacts
  ''';

    return connection.query(sql).then((Iterable rows) =>
      rows.map(_rowToBaseContact));
  }

  /**
   * Create a new [Model.BaseContact].
   */
  static Future<Model.BaseContact> create(Model.BaseContact contact) {
    String sql = '''
    INSERT INTO contacts (full_name, contact_type, enabled)
    VALUES (@full_name, @contact_type, @enabled)
    RETURNING id;
  ''';

    Map parameters =
      {'full_name'    : contact.fullName,
       'contact_type' : contact.contactType,
       'enabled'      : contact.enabled};

    return connection.query(sql, parameters)
      .then((Iterable rows) =>
          rows.length > 0
            ? (contact..id = rows.first.id)
            : new Future.error(new StateError('No contact was created!')))
      .catchError((error, stackTrace) {
        log.severe('SQL: $sql :: Parameters : $parameters', error, stackTrace);

        return new Future.error(error, stackTrace);
      });
  }


  static Future<Iterable<Model.PhoneNumber>> phones(int contactID, int receptionID) {
    String sql = '''
        SELECT phonenumbers
        FROM reception_contacts
        WHERE contact_id = @contactID AND reception_id = @receptionID''';

    Map parameters =
      {'contactID': contactID,
       'receptionID': receptionID};

    return connection.query(sql, parameters).then((rows) {
      if ((rows as Iterable).isEmpty) {
        throw new Storage.NotFound('No contact found with ID $contactID'
                                   ' in reception with ID $receptionID');
      }

      Iterable<Map> phonesMap = (rows as Iterable).first.phonenumbers;


      return phonesMap.map(_mapToPhone);
    });
  }


  static Future<Iterable<Model.MessageEndpoint>> endpoints(int contactID, int receptionID) {
      String sql = '''
        SELECT address, address_type, confidential, enabled, priority, 
              description
        FROM messaging_end_points 
        WHERE contact_id = @contactID AND reception_id = @receptionID''';

      Map parameters =
        {'contactID': contactID,
         'receptionID': receptionID};

      return connection.query(sql, parameters).then((rows) =>
        (rows as Iterable).map((row) =>
          new Model.MessageEndpoint.fromMap(
            {'address'      : row.address,
             'type'         : row.address_type,
             'confidential' : row.confidential,
             'enabled'      : row.enabled,
             'priority'     : row.priority,
             'description'  : row.description,
             })
          ));

  }

  static Future<Iterable<Model.Contact>> list(int receptionId) {
    String sql = '''
    SELECT rcpcon.reception_id, 
           rcpcon.contact_id, 
           rcpcon.wants_messages, 
           rcpcon.attributes, 
           rcpcon.enabled as rcpenabled,
           (SELECT row_to_json(distribution_column_seperated_roles)
              FROM (SELECT (SELECT array_to_json(array_agg(row_to_json(tmp_to)))
                            FROM (SELECT 
                                    recipient_reception_id as reception_id,
                                    reception.full_name    as reception_name,
                                    contact.full_name      as contact_name,
                                    recipient_contact_id   as contact_id
                                  FROM distribution_list dl JOIN receptions reception ON (recipient_reception_id = reception.id)
                                                            JOIN contacts contact ON (recipient_contact_id = contact.id) 
                                  WHERE dl.owner_reception_id = rcpcon.reception_id AND 
                                        dl.owner_contact_id = rcpcon.contact_id AND
                                        dl.role = 'to'
                                 ) tmp_to
                           ) AS to,
               
                           (SELECT array_to_json(array_agg(row_to_json(tmp_cc)))
                            FROM (SELECT 
                                    recipient_reception_id as reception_id,
                                    reception.full_name    as reception_name,
                                    contact.full_name      as contact_name,
                                    recipient_contact_id   as contact_id
                                  FROM distribution_list dl JOIN receptions reception ON (recipient_reception_id = reception.id)
                                                            JOIN contacts contact ON (recipient_contact_id = contact.id) 
                                  WHERE dl.owner_reception_id = rcpcon.reception_id AND 
                                        dl.owner_contact_id = rcpcon.contact_id AND 
                                        dl.role = 'cc'
                                 ) tmp_cc
                           ) AS cc,
               
                           (SELECT array_to_json(array_agg(row_to_json(tmp_bcc)))
                            FROM (SELECT 
                                    recipient_reception_id as reception_id,
                                    reception.full_name    as reception_name,
                                    contact.full_name      as contact_name,
                                    recipient_contact_id   as contact_id
                                  FROM distribution_list dl JOIN receptions reception ON (recipient_reception_id = reception.id)
                                                            JOIN contacts contact ON (recipient_contact_id = contact.id) 
                                  WHERE dl.owner_reception_id = rcpcon.reception_id AND 
                                        dl.owner_contact_id = rcpcon.contact_id AND
                                        dl.role = 'bcc'
                                 ) tmp_bcc
                           ) AS bcc
                   ) distribution_column_seperated_roles
             ) as distribution_list,
           con.full_name, 
           con.contact_type, 
           con.enabled as conenabled,
           rcpcon.phonenumbers as phone,

             (SELECT coalesce(array_to_json(array_agg(row_to_json(contact_end_point))), '[]')
              FROM (SELECT address, 
                           address_type AS type, 
                           confidential, 
                           enabled,
                           priority,
                           description
                    FROM messaging_end_points
                    WHERE reception_id = rcpcon.reception_id AND
                          contact_id = rcpcon.contact_id
                    ORDER BY priority ASC) contact_end_point) AS endpoints

    FROM contacts con 
      JOIN reception_contacts rcpcon on con.id = rcpcon.contact_id
    WHERE rcpcon.reception_id = @receptionid''';

    Map parameters = {'receptionid' : receptionId};

    return connection.query(sql, parameters).then((rows) =>
      (rows as Iterable).map(_rowToContact));
  }

  static Future<Model.Contact> get(int receptionId, int contactId) {
      String sql = '''
      SELECT rcpcon.reception_id, 
             rcpcon.contact_id, 
             rcpcon.wants_messages, 
             rcpcon.attributes, 
             rcpcon.enabled as rcpenabled,
             (SELECT row_to_json(distribution_column_seperated_roles)
              FROM (SELECT (SELECT array_to_json(array_agg(row_to_json(tmp_to)))
                            FROM (SELECT 
                                    recipient_reception_id as reception_id,
                                    reception.full_name    as reception_name,
                                    contact.full_name      as contact_name,
                                    recipient_contact_id   as contact_id
                                  FROM distribution_list dl JOIN receptions reception ON (recipient_reception_id = reception.id)
                                                            JOIN contacts contact ON (recipient_contact_id = contact.id) 
                                  WHERE dl.owner_reception_id = rcpcon.reception_id AND 
                                        dl.owner_contact_id = rcpcon.contact_id AND
                                        dl.role = 'to'
                                 ) tmp_to
                           ) AS to,
               
                           (SELECT array_to_json(array_agg(row_to_json(tmp_cc)))
                            FROM (SELECT 
                                    recipient_reception_id as reception_id,
                                    reception.full_name    as reception_name,
                                    contact.full_name      as contact_name,
                                    recipient_contact_id   as contact_id
                                  FROM distribution_list dl JOIN receptions reception ON (recipient_reception_id = reception.id)
                                                            JOIN contacts contact ON (recipient_contact_id = contact.id) 
                                  WHERE dl.owner_reception_id = rcpcon.reception_id AND 
                                        dl.owner_contact_id = rcpcon.contact_id AND 
                                        dl.role = 'cc'
                                 ) tmp_cc
                           ) AS cc,
               
                           (SELECT array_to_json(array_agg(row_to_json(tmp_bcc)))
                            FROM (SELECT 
                                    recipient_reception_id as reception_id,
                                    reception.full_name    as reception_name,
                                    contact.full_name      as contact_name,
                                    recipient_contact_id   as contact_id
                                  FROM distribution_list dl JOIN receptions reception ON (recipient_reception_id = reception.id)
                                                            JOIN contacts contact ON (recipient_contact_id = contact.id) 
                                  WHERE dl.owner_reception_id = rcpcon.reception_id AND 
                                        dl.owner_contact_id = rcpcon.contact_id AND
                                        dl.role = 'bcc'
                                 ) tmp_bcc
                           ) AS bcc
                   ) distribution_column_seperated_roles
             ) as distribution_list,
             con.full_name, 
             con.contact_type, 
             con.enabled as conenabled,
             rcpcon.phonenumbers as phone,

             (SELECT coalesce(array_to_json(array_agg(row_to_json(contact_end_point))), '[]')
              FROM (SELECT address, 
                           address_type AS type, 
                           confidential, 
                           enabled,
                           priority,
                           description
                    FROM messaging_end_points
                    WHERE reception_id = rcpcon.reception_id AND
                          contact_id = rcpcon.contact_id
                    ORDER BY priority ASC) contact_end_point) AS endpoints
        
          FROM   contacts con 
            JOIN reception_contacts rcpcon on con.id = rcpcon.contact_id
          WHERE  rcpcon.reception_id = @receptionid
             AND rcpcon.contact_id = @contactid ;''';

      Map parameters = {'receptionid' : receptionId,
                        'contactid': contactId};

      return connection.query(sql, parameters).then((rows) {

        if(rows != null && rows.length == 1) {
          return (_rowToContact(rows.first));
        } else {
          throw new Storage.NotFound
            ('ContactID: $contactId, ReceptionID: $receptionId');
        }
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new Future.error(error, stackTrace);
      });
  }

  /**
   * Retrieve all contacts from an organization.
   */
  static Future<Iterable<Model.BaseContact>> organizationContacts(int organizationId) {
    String sql = '''
    SELECT DISTINCT c.id, c.full_name, c.enabled, c.contact_type
    FROM receptions r
      JOIN reception_contacts rc on r.id = rc.reception_id
      JOIN contacts c on rc.contact_id = c.id
    WHERE r.organization_id = @organization_id
    ORDER BY c.id
  ''';

    Map parameters = {'organization_id': organizationId};

    return connection.query(sql, parameters)
      .then((Iterable rows) => rows.map(_rowToBaseContact));
  }

  /**
   * Retrieve all reception id's of a contact.
   */
  static Future<Iterable<int>> receptions (int contactID) {
    String sql = '''

    SELECT reception_id
        FROM reception_contacts 
      WHERE 
      contact_id  =@contactID''';

    Map parameters = {'contactID': contactID};

    return connection.query(sql, parameters).then((rows) =>
      (rows as Iterable).map((var row) => row.reception_id));
  }

  /**
   * Removes a contact from the database.
   */
  static Future<int> remove (int contactID) {
    String sql = '''
      DELETE FROM contacts
      WHERE id=@id;
    ''';

    Map parameters = {'id': contactID};
    return connection.execute(sql, parameters)
      .then((int rowsAffected) =>
        rowsAffected > 0
          ? null
          : new Future.error(new Storage.NotFound('$contactID')));
  }

  static Future<int> update(Model.BaseContact contact) {
    String sql = '''
    UPDATE contacts
    SET full_name=@full_name, contact_type=@contact_type, enabled=@enabled
    WHERE id=@id;
  ''';

    Map parameters =
      {'full_name'    : contact.fullName,
       'contact_type' : contact.contactType,
       'enabled'      : contact.enabled,
       'id'           : contact.id};

    return connection.execute(sql, parameters)
      .then((int rowsAffected) =>
        rowsAffected > 0
          ? contact
          : new Future.error(new Storage.NotFound('en')));
  }

  /**
   * Converts a database row into a [Model.Contact] object.
   */
  static Model.Contact _rowToContact (var row) {
    var distributionList = new Model.MessageRecipientList.empty();

    Model.Role.RECIPIENT_ROLES.forEach((String role) {
       Iterable nextVal = row.distribution_list[role] == null
         ? []
         : row.distribution_list[role];

       nextVal.forEach((Map dlistMap) {
                        distributionList.add(new Model.MessageRecipient.fromMap({'reception' :
                        {'id'   : dlistMap['reception_id'],
                         'name' : dlistMap['reception_name']},
                       'contact'   :
                        {'id'   : dlistMap['contact_id'],
                         'name' : dlistMap['contact_name']}},
                         role : role));
                    });
      });

    Iterable<Model.MessageEndpoint> endpointIterable =
      row.endpoints.map((Map map) =>
        new Model.MessageEndpoint.fromMap(map));

    Iterable<Model.PhoneNumber> phoneIterable = row.phone == null
       ? []
       : row.phone.map ((Map map) =>
           new Model.PhoneNumber.fromMap(map));

    List backupContacts = [];
    List emailaddresses = [];
    List handling = [];
    List tags = [];
    List workhours = [];

    List departments = [];
    List infos = [];
    List titles = [];
    List relations = [];
    List responsibilities = [];
    List messagePrerequisites = [];

    if(row.attributes != null) {
      if (row.attributes.containsKey (Model.ContactJSONKey.backup)) {
        backupContacts = row.attributes[Model.ContactJSONKey.backup];
      }

      if (row.attributes.containsKey (Model.ContactJSONKey.emailaddresses)) {
        emailaddresses = row.attributes[Model.ContactJSONKey.emailaddresses];
      }

      if(row.attributes.containsKey (Model.ContactJSONKey.handling)) {
        handling = row.attributes[Model.ContactJSONKey.handling];
      }

      // Tags
      if (row.attributes.containsKey (Model.ContactJSONKey.tags)) {
        tags = row.attributes[Model.ContactJSONKey.tags];
      }

      // Work hours
      if (row.attributes.containsKey (Model.ContactJSONKey.workhours)) {
        workhours = row.attributes[Model.ContactJSONKey.workhours];
      }

      // Department
      if (row.attributes.containsKey (Model.ContactJSONKey.departments)) {
        departments = row.attributes[Model.ContactJSONKey.departments];
      }

      // Info's
      if (row.attributes.containsKey (Model.ContactJSONKey.infos)) {
        infos = row.attributes[Model.ContactJSONKey.infos];
      }

      // Titles
      if (row.attributes.containsKey (Model.ContactJSONKey.titles)) {
        titles = row.attributes[Model.ContactJSONKey.titles];
      }

      // Relations
      if (row.attributes.containsKey (Model.ContactJSONKey.relations)) {
        var relationValue = row.attributes[Model.ContactJSONKey.relations];

        if (relationValue is String) {
          relations = [row.attributes[Model.ContactJSONKey.relations]];
        }
        else if (relationValue is Iterable) {
          relations = row.attributes[Model.ContactJSONKey.relations];
        }
        else {
          log.severe ('Bad relations value: $relationValue');
        }
      }

      // Responsiblities
      if(row.attributes.containsKey (Model.ContactJSONKey.responsibilities)) {
        responsibilities = row.attributes[Model.ContactJSONKey.responsibilities];
      }

      // messagePrerequisites
      if (row.attributes.containsKey (Model.ContactJSONKey.messagePrerequisites)) {
        messagePrerequisites = row.attributes[Model.ContactJSONKey.messagePrerequisites];
      }

    }

    Model.Contact contact = new Model.Contact.empty()
      ..receptionID = row.reception_id
      ..ID = row.contact_id
      ..wantsMessage = row.wants_messages
      ..enabled = row.rcpenabled && row.conenabled
      ..fullName = row.full_name
      ..contactType = row.contact_type
      ..phones.addAll(phoneIterable)
      ..endpoints.addAll(endpointIterable)
      ..distributionList = distributionList
      ..backupContacts = backupContacts
      ..departments = departments
      ..emailaddresses = emailaddresses
      ..handling = handling
      ..infos = infos
      ..titles = titles
      ..relations.addAll(relations)
      ..responsibilities = responsibilities
      ..tags = tags
      ..workhours = workhours
      ..messagePrerequisites = messagePrerequisites;

    return contact;
  }

  static Model.PhoneNumber _mapToPhone (Map map) {

    Model.PhoneNumber p =
      new Model.PhoneNumber.empty()
        ..billing_type = map['billing_type']
        ..description = map['description']
        ..value = map['value']
        ..type = map['kind'];
    if(map['tag'] != null) {
      p.tags.add(map['tag']);
    }

    return p;
  }

  static Model.BaseContact _rowToBaseContact (var row) =>
    new Model.BaseContact.empty()
      ..id = row.id
      ..fullName = row.full_name
      ..contactType = row.contact_type
      ..enabled = row.enabled;

}
