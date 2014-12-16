part of adaheads.server.database;

Future<int> _createReception(ORDatabase.Connection connection, int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) {
  String sql = '''
    INSERT INTO receptions (organization_id, full_name, attributes, extradatauri, enabled, reception_telephonenumber)
    VALUES (@organization_id, @full_name, @attributes, @extradatauri, @enabled, @reception_telephonenumber)
    RETURNING id;
  ''';

  Map parameters =
    {'organization_id': organizationId,
     'full_name'      : fullName,
     'attributes'     : attributes == null ? '{}' : attributes,
     'extradatauri'   : extradatauri,
     'enabled'        : enabled,
     'reception_telephonenumber': number};

  return connection.query(sql, parameters).then((rows) => rows.first.id);
}

Future<int> _deleteReception(ORDatabase.Connection connection, int id) {
  String sql = '''
      DELETE FROM receptions
      WHERE id=@id;
    ''';

  Map parameters = {'id': id};
  return connection.execute(sql, parameters);
}

Future<List<model.Reception>> _getOrganizationReceptionList(ORDatabase.Connection connection, int organizationId) {
  String sql = '''
    SELECT id, organization_id, full_name, attributes, extradatauri, enabled, reception_telephonenumber
    FROM receptions
    WHERE organization_id=@organization_id
  ''';

  Map parameters = {'organization_id': organizationId};

  return connection.query(sql, parameters).then((List rows) {
    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(
          row.id,
          row.organization_id,
          row.full_name,
          row.attributes != null ? row.attributes : '{}',
          row.extradatauri,
          row.enabled,
          row.reception_telephonenumber));
    }
    return receptions;
  });
}

Future<model.Reception> _getReception(ORDatabase.Connection connection, int receptionId) {
  String sql = '''
    SELECT id, organization_id, full_name, attributes, extradatauri, enabled, reception_telephonenumber
    FROM receptions
    WHERE id = @id
  ''';

  Map parameters = {'id': receptionId};

  return connection.query(sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      var row = rows.first;
      return new model.Reception(
          row.id,
          row.organization_id,
          row.full_name,
          row.attributes != null ? row.attributes : '{}',
          row.extradatauri,
          row.enabled,
          row.reception_telephonenumber);
    }
  });
}

Future<List<model.Reception>> _getReceptionList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT id, organization_id, full_name, attributes, extradatauri, enabled, reception_telephonenumber
    FROM receptions
  ''';

  return connection.query(sql).then((List rows) {
    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(
          row.id,
          row.organization_id,
          row.full_name,
          row.attributes != null ? row.attributes : '{}',
          row.extradatauri,
          row.enabled,
          row.reception_telephonenumber));
    }
    return receptions;
  });
}

Future<int> _updateReception(ORDatabase.Connection connection, int id, int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) {
  String sql = '''
    UPDATE receptions
    SET full_name=@full_name, 
        attributes=@attributes, 
        extradatauri=@extradatauri, 
        enabled=@enabled, 
        reception_telephonenumber=@reception_telephonenumber,
        organization_id=@organization_id
    WHERE id=@id;
  ''';

  Map parameters =
    {'full_name'      : fullName,
     'attributes'     : attributes == null ? '{}' : attributes,
     'extradatauri'   : extradatauri,
     'enabled'        : enabled,
     'id'             : id,
     'organization_id': organizationId,
     'reception_telephonenumber': number};

  return connection.execute(sql, parameters);
}

Future<List<model.Reception>> _getContactReceptions(ORDatabase.Connection connection, int contactId) {
  String sql = '''
    SELECT r.id, r.organization_id, r.full_name, r.attributes, r.extradatauri, r.enabled, r.reception_telephonenumber
    FROM reception_contacts rc
      JOIN receptions r on rc.reception_id = r.id
    WHERE rc.contact_id=@contact_id
  ''';

  Map parameters = {'contact_id': contactId};

  return connection.query(sql, parameters).then((List rows) {
    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(
          row.id,
          row.organization_id,
          row.full_name,
          row.attributes != null ? row.attributes : '{}',
          row.extradatauri,
          row.enabled,
          row.reception_telephonenumber));
    }
    return receptions;
  });
}
