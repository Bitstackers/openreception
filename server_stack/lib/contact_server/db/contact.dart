part of contactserver.database;

abstract class Contact {

  Logger log = new Logger('$libraryName.Contact');

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

      Model.PhoneNumber mapToPhone (Map map) {

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

      return phonesMap.map(mapToPhone);
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
                                    contact.full_name      as conctact_name,
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
                                    contact.full_name      as conctact_name,
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
                                    contact.full_name      as conctact_name,
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
                                    contact.full_name      as conctact_name,
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
      });
  }

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

    String department = '';
    String info = '';
    String title = '';
    String relations = '';
    String responsibility = '';

    if(row.attributes != null) {
      backupContacts
        = row.attributes.containsKey (Model.ContactJSONKey.backup)
          ? row.attributes[Model.ContactJSONKey.backup]
          : [];

      emailaddresses
        = row.attributes.containsKey (Model.ContactJSONKey.emailaddresses)
          ? row.attributes[Model.ContactJSONKey.emailaddresses]
          : [];

      handling
        = row.attributes.containsKey (Model.ContactJSONKey.handling)
          ? row.attributes[Model.ContactJSONKey.handling]
          : [];


      tags
        = row.attributes.containsKey (Model.ContactJSONKey.tags)
          ? row.attributes[Model.ContactJSONKey.tags]
          : [];

      workhours
        = row.attributes.containsKey (Model.ContactJSONKey.workhours)
          ? row.attributes[Model.ContactJSONKey.workhours]
          : [];

      department
        = row.attributes.containsKey (Model.ContactJSONKey.department)
          ? row.attributes[Model.ContactJSONKey.department]
          : '';

      info
        = row.attributes.containsKey (Model.ContactJSONKey.info)
          ? row.attributes[Model.ContactJSONKey.info]
          : '';

      title
        = row.attributes.containsKey (Model.ContactJSONKey.position)
          ? row.attributes[Model.ContactJSONKey.position]
          : '';

      relations
        = row.attributes.containsKey (Model.ContactJSONKey.relations)
          ? row.attributes[Model.ContactJSONKey.relations]
          : '';

      responsibility
        = row.attributes.containsKey (Model.ContactJSONKey.responsibility)
          ? row.attributes[Model.ContactJSONKey.responsibility]
          : '';

    }


    Model.Contact contact = new Model.Contact.none()
      ..receptionID = row.reception_id
      ..ID = row.contact_id
      ..wantsMessage = row.wants_messages
      ..enabled = row.rcpenabled && row.conenabled
      ..fullName = row.full_name
      ..contactType = row.contact_type
      ..phones = ([]..addAll(phoneIterable))
      ..endpoints = ([]..addAll(endpointIterable))
      ..distributionList = distributionList
      ..backupContacts = backupContacts
      ..department = department
      ..emailaddresses = emailaddresses
      ..handling = handling
      ..info = info
      ..position = title
      ..relations = relations
      ..responsibility = responsibility
      ..tags = tags
      ..workhours = workhours;

    //TODO: Add attributes.


    //FIXME: The format should be changed in the SQL return value.

    return contact;
  }

}
