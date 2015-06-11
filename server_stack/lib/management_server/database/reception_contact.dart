part of adaheads.server.database;


Future<int> _createReceptionContact(ORDatabase.Connection connection, int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) {
  String sql = '''
    INSERT INTO reception_contacts (reception_id, contact_id, wants_messages, phonenumbers, attributes, enabled)
    VALUES (@reception_id, @contact_id, @wants_messages, @phonenumbers, @attributes, @enabled);
  ''';

  Map parameters =
    {'reception_id'         : receptionId,
     'contact_id'           : contactId,
     'wants_messages'       : wantMessages,
     'phonenumbers'         : phonenumbers == null ? '[]' : JSON.encode(phonenumbers),
     'attributes'           : attributes   == null ? {} : attributes,
     'enabled'              : enabled};

  return connection.execute(sql, parameters);
}

Future<int> _deleteReceptionContact(ORDatabase.Connection connection, int receptionId, int contactId) {
  String sql = '''
    DELETE FROM reception_contacts
    WHERE reception_id=@reception_id AND contact_id=@contact_id;
  ''';

  Map parameters = {'reception_id' : receptionId,
                    'contact_id'   : contactId};
  return connection.execute(sql, parameters);
}

Future<int> _updateReceptionContact(ORDatabase.Connection connection, int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) {
  String sql = '''
    UPDATE reception_contacts
    SET wants_messages=@wants_messages,
        attributes=@attributes,
        enabled=@enabled,
        phonenumbers=@phonenumbers
    WHERE reception_id=@reception_id AND contact_id=@contact_id;
  ''';

  Map parameters =
    {'reception_id'         : receptionId,
     'contact_id'           : contactId,
     'wants_messages'       : wantMessages,
     'phonenumbers'         : phonenumbers == null ? '[]' : JSON.encode(phonenumbers),
     'attributes'           : attributes == null ? {}   : attributes,
     'enabled'              : enabled};

  return connection.execute(sql, parameters);
}

Future<List<model.ReceptionContact_ReducedReception>> _getAContactsReceptionContactList(ORDatabase.Connection connection, int contactId) {
  String sql = '''
    SELECT rc.contact_id,
           rc.wants_messages,
           rc.attributes,
           rc.enabled as contactenabled,
           rc.phonenumbers,
            r.organization_id,
            r.id as reception_id,
            r.full_name as receptionname,
            r.enabled as receptionenabled,
            r.organization_id
    FROM reception_contacts rc
      JOIN receptions r on rc.reception_id = r.id
    WHERE rc.contact_id = @contact_id
  ''';

  Map parameters = {'contact_id': contactId};

  return connection.query(sql, parameters).then((List rows) {
    List<model.ReceptionContact_ReducedReception> contacts = new List<model.ReceptionContact_ReducedReception>();
    for(var row in rows) {
      contacts.add(new model.ReceptionContact_ReducedReception(
        row.contact_id,
        row.wants_messages,
        row.attributes == null ? {} : row.attributes,
        row.contactenabled,
        row.phonenumbers == null ? new List<Map>() : row.phonenumbers,
        row.reception_id,
        row.receptionname,
        row.receptionenabled,
        row.organization_id));
    }
    return contacts;
  });
}

Future<List<model.Organization>> _getAContactsOrganizationList(ORDatabase.Connection connection, int contactId) {
  String sql = '''
    SELECT DISTINCT o.id, o.full_name, o.billing_type, o.flag
    FROM reception_contacts rc
    JOIN receptions r on rc.reception_id = r.id
    JOIN organizations o on r.organization_id = o.id
    WHERE rc.contact_id = @contact_id
  ''';

  Map parameters = {'contact_id': contactId};

  return connection.query(sql, parameters).then((List rows) {
    List<model.Organization> organizations = new List<model.Organization>();
    for(var row in rows) {
      organizations.add(new model.Organization(row.id, row.full_name, row.billing_type, row.flag));
    }
    return organizations;
  });
}

Future _moveReceptionContact(ORDatabase.Connection connection, int receptionId, int oldContactId, int newContactId) {
  String sql = '''
    UPDATE reception_contacts
    SET contact_id = @new_contact_id
    WHERE reception_id=@reception_id AND contact_id=@contact_id;
  ''';

  Map parameters =
    {'reception_id'   : receptionId,
     'contact_id'     : oldContactId,
     'new_contact_id' : newContactId};

  return connection.execute(sql, parameters);
}
