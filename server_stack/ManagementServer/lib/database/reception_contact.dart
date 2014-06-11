part of adaheads.server.database;

Future<model.CompleteReceptionContact> _getReceptionContact(Pool pool, int receptionId, int contactId) {
  String sql = '''
    SELECT c.id, 
           c.full_name, 
           c.contact_type, 
           c.enabled as contactenabled, 
          rc.reception_id, 
          rc.wants_messages,
          rc.attributes, 
          rc.enabled as receptionenabled,
          rc.phonenumbers
    FROM reception_contacts rc
      JOIN contacts c on rc.contact_id = c.id
    WHERE rc.reception_id = @reception_id AND rc.contact_id = @contact_id
  ''';

  Map parameters =
    {'reception_id': receptionId,
     'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;

      return new model.CompleteReceptionContact(
          row.id,
          row.full_name,
          row.contact_type,
          row.contactenabled,
          row.reception_id,
          row.wants_messages,
          row.attributes == null ? {} : JSON.decode(row.attributes),
          row.receptionenabled,
          row.phonenumbers == null ? [] : JSON.decode(row.phonenumbers));
    }
  });
}

Future<List<model.CompleteReceptionContact>> _getReceptionContactList(Pool pool, int receptionId) {
  String sql = '''
    SELECT c.id, 
           c.full_name, 
           c.contact_type, 
           c.enabled as contactenabled, 
          rc.reception_id, 
          rc.wants_messages,
          rc.attributes, 
          rc.enabled as receptionenabled,
          rc.phonenumbers
    FROM reception_contacts rc
      JOIN contacts c on rc.contact_id = c.id
    WHERE rc.reception_id = @reception_id
  ''';

  Map parameters = {'reception_id': receptionId};

  return query(pool, sql, parameters).then((rows) {
    List<model.CompleteReceptionContact> receptions = new List<model.CompleteReceptionContact>();
    for(var row in rows) {
      receptions.add(new model.CompleteReceptionContact(
          row.id,
          row.full_name,
          row.contact_type,
          row.contactenabled,
          row.reception_id,
          row.wants_messages,
          row.attributes == null ? {} : JSON.decode(row.attributes),
          row.receptionenabled,
          row.phonenumbers == null ? [] : JSON.decode(row.phonenumbers)));
    }
    return receptions;
  });
}

Future<int> _createReceptionContact(Pool pool, int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) {
  String sql = '''
    INSERT INTO reception_contacts (reception_id, contact_id, wants_messages, phonenumbers, attributes, enabled)
    VALUES (@reception_id, @contact_id, @wants_messages, @phonenumbers, @attributes, @enabled);
  ''';

  Map parameters =
    {'reception_id'         : receptionId,
     'contact_id'           : contactId,
     'wants_messages'       : wantMessages,
     'phonenumbers'         : phonenumbers == null ? '[]' : JSON.encode(phonenumbers),
     'attributes'           : attributes == null ? '{}' : JSON.encode(attributes),
     'enabled'              : enabled};

  return execute(pool, sql, parameters);
}

Future<int> _deleteReceptionContact(Pool pool, int receptionId, int contactId) {
  String sql = '''
    DELETE FROM reception_contacts
    WHERE reception_id=@reception_id AND contact_id=@contact_id;
  ''';

  Map parameters = {'reception_id' : receptionId,
                    'contact_id'   : contactId};
  return execute(pool, sql, parameters);
}

Future<int> _updateReceptionContact(Pool pool, int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) {
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
     'attributes'           : attributes == null ? '{}' : JSON.encode(attributes),
     'enabled'              : enabled};

  return execute(pool, sql, parameters);
}

Future<List<model.ReceptionContact_ReducedReception>> _getAContactsReceptionContactList(Pool pool, int contactId) {
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

  return query(pool, sql, parameters).then((rows) {
    List<model.ReceptionContact_ReducedReception> contacts = new List<model.ReceptionContact_ReducedReception>();
    for(var row in rows) {
      contacts.add(new model.ReceptionContact_ReducedReception(
        row.contact_id,
        row.wants_messages,
        row.attributes == null ? {} : JSON.decode(row.attributes),
        row.contactenabled,
        row.phonenumbers == null ? [] : JSON.decode(row.phonenumbers),
        row.reception_id,
        row.receptionname,
        row.receptionenabled,
        row.organization_id));
    }
    return contacts;
  });
}

Future<List<model.Organization>> _getAContactsOrganizationList(Pool pool, int contactId) {
  String sql = '''
    SELECT DISTINCT o.id, o.full_name, o.bill_type, o.flag
    FROM reception_contacts rc
    JOIN receptions r on rc.reception_id = r.id
    JOIN organizations o on r.organization_id = o.id
    WHERE rc.contact_id = @contact_id
  ''';

  Map parameters = {'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    List<model.Organization> organizations = new List<model.Organization>();
    for(var row in rows) {
      organizations.add(new model.Organization(row.id, row.full_name, row.bill_type, row.flag));
    }
    return organizations;
  });
}
