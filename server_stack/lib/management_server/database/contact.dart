part of adaheads.server.database;

Future<int> _createContact(ORDatabase.Connection connection, String fullName, String contact_type, bool enabled) {
  String sql = '''
    INSERT INTO contacts (full_name, contact_type, enabled)
    VALUES (@full_name, @contact_type, @enabled)
    RETURNING id;
  ''';

  Map parameters =
    {'full_name'    : fullName,
     'contact_type' : contact_type,
     'enabled'      : enabled};

  return connection.query(sql, parameters).then((rows) => rows.first.id);
}

Future<int> _deleteContact(ORDatabase.Connection connection, int contactId) {
  String sql = '''
      DELETE FROM contacts
      WHERE id=@id;
    ''';

  Map parameters = {'id': contactId};
  return connection.execute(sql, parameters);
}

Future<List<model.ReceptionColleague>> _getContactColleagues(ORDatabase.Connection connection, int contactId) {
  String sql = '''
     SELECT
        r.organization_id as organizationid,
        r.id as receptionid,
        r.full_name as receptionname,
        r.enabled as receptionenabled,
        c.id as contactid,
        c.full_name as contactname,
        c.enabled as contactenabled,
        c.contact_type as contacttype
     FROM reception_contacts rc
        JOIN receptions r on rc.reception_id = r.id
        JOIN contacts c on rc.contact_id = c.id
        JOIN (SELECT reception_id
              FROM reception_contacts
              WHERE contact_id = @contactid) cr on cr.reception_id = rc.reception_id
     ORDER BY r.full_name, c.full_name
    ''';

  Map parameters = {'contactid': contactId};

  return connection.query(sql, parameters).then((List rows) {
    Map<int, model.ReceptionColleague> receptions = new Map<int, model.ReceptionColleague>();

    for(var row in rows) {
      int receptionId = row.receptionid;
      if(!receptions.containsKey(receptionId)) {
        model.ReceptionColleague reception = new model.ReceptionColleague(row.receptionid, row.organizationid, row.receptionname, row.receptionenabled);
        receptions[receptionId] = reception;
      }

      model.Colleague colleague = new model.Colleague(row.contactid, row.contactname, row.contactenabled, row.contacttype);
      receptions[receptionId].Colleagues.add(colleague);
    }

    return receptions.values.toList();
  });
}

Future<model.Contact> _getContact(ORDatabase.Connection connection, int contactId) {
  String sql = '''
    SELECT id, full_name, contact_type, enabled
    FROM contacts
    WHERE id = @id
  ''';

  Map parameters = {'id': contactId};

  return connection.query(sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      var row = rows.first;
      return new model.Contact(row.id, row.full_name, row.contact_type, row.enabled);
    }
  });
}

Future<List<model.Contact>> _getContactList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT id, full_name, contact_type, enabled
    FROM contacts
  ''';

  return connection.query(sql).then((List rows) {
    List<model.Contact> contacts = new List<model.Contact>();
    for(var row in rows) {
      contacts.add(new model.Contact(row.id, row.full_name, row.contact_type, row.enabled));
    }
    return contacts;
  });
}

Future<List<String>> _getContactTypeList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT value
    FROM contact_types;
  ''';

  return connection.query(sql).then((List Rows) => Rows.map((row) => row.value).toList());
}

Future<List<String>> _getAddressTypeList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT value
    FROM messaging_address_types;
  ''';

  return connection.query(sql).then((List Rows) => Rows.map((row) => row.value).toList());
}

Future<int> _updateContact(ORDatabase.Connection connection, int contactId, String fullName, String contact_type, bool enabled) {
  String sql = '''
    UPDATE contacts
    SET full_name=@full_name, contact_type=@contact_type, enabled=@enabled
    WHERE id=@id;
  ''';

  Map parameters =
    {'full_name'    : fullName,
     'contact_type' : contact_type,
     'enabled'      : enabled,
     'id'           : contactId};

  return connection.execute(sql, parameters);
}

Future<List<model.Contact>> _getOrganizationContactList(ORDatabase.Connection connection, int organizationId) {
  String sql = '''
    SELECT DISTINCT c.id, c.full_name, c.enabled, c.contact_type
    FROM receptions r
      JOIN reception_contacts rc on r.id = rc.reception_id
      JOIN contacts c on rc.contact_id = c.id
    WHERE r.organization_id = @organization_id
    ORDER BY c.id
  ''';

  Map parameters = {'organization_id': organizationId};

  return connection.query(sql, parameters).then((List rows) {
    List<model.Contact> contacts = new List<model.Contact>();
    for(var row in rows) {
      contacts.add(new model.Contact(row.id, row.full_name, row.contact_type, row.enabled));
    }
    return contacts;
  });
}
