part of adaheads.server.database;

Future<int> _createReception(Pool pool, int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) {
  String sql = '''
    INSERT INTO receptions (organization_id, full_name, attributes, extradatauri, enabled, reception_telephonenumber)
    VALUES (@organization_id, @full_name, @attributes, @extradatauri, @enabled, @reception_telephonenumber)
    RETURNING id;
  ''';

  Map parameters =
    {'organization_id': organizationId,
     'full_name'      : fullName,
     'attributes'     : attributes == null ? '{}' : JSON.encode(attributes),
     'extradatauri'   : extradatauri,
     'enabled'        : enabled,
     'reception_telephonenumber': number};

  return query(pool, sql, parameters).then((rows) => rows.first.id);
}

Future<int> _deleteReception(Pool pool, int organizationId, int id) {
  String sql = '''
      DELETE FROM receptions
      WHERE id=@id AND organization_id=@organization_id;
    ''';

  Map parameters =
    {'id': id,
     'organization_id': organizationId};
  return execute(pool, sql, parameters);
}

Future<List<model.Reception>> _getOrganizationReceptionList(Pool pool, int organizationId) {
  String sql = '''
    SELECT id, organization_id, full_name, attributes, extradatauri, enabled, reception_telephonenumber
    FROM receptions
    WHERE organization_id=@organization_id
  ''';

  Map parameters = {'organization_id': organizationId};

  return query(pool, sql, parameters).then((rows) {
    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(
          row.id,
          row.organization_id,
          row.full_name,
          JSON.decode(row.attributes != null ? row.attributes : '{}'),
          row.extradatauri,
          row.enabled,
          row.reception_telephonenumber));
    }
    return receptions;
  });
}

Future<model.Reception> _getReception(Pool pool, int organizationId, int receptionId) {
  String sql = '''
    SELECT id, organization_id, full_name, attributes, extradatauri, enabled, reception_telephonenumber
    FROM receptions
    WHERE id = @id AND organization_id=@organization_id
  ''';

  Map parameters =
    {'id': receptionId,
     'organization_id': organizationId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new model.Reception(
          row.id,
          row.organization_id,
          row.full_name,
          JSON.decode(row.attributes != null ? row.attributes : '{}'),
          row.extradatauri,
          row.enabled,
          row.reception_telephonenumber);
    }
  });
}

Future<List<model.Reception>> _getReceptionList(Pool pool) {
  String sql = '''
    SELECT id, organization_id, full_name, attributes, extradatauri, enabled, reception_telephonenumber
    FROM receptions
  ''';

  return query(pool, sql).then((rows) {

    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(
          row.id,
          row.organization_id,
          row.full_name,
          JSON.decode(row.attributes != null ? row.attributes : '{}'),
          row.extradatauri,
          row.enabled,
          row.reception_telephonenumber));
    }
    return receptions;
  });
}

Future<int> _updateReception(Pool pool, int organizationId, int id, String fullName, Map attributes, String extradatauri, bool enabled, String number) {
  String sql = '''
    UPDATE receptions
    SET full_name=@full_name, attributes=@attributes, extradatauri=@extradatauri, enabled=@enabled, reception_telephonenumber=@reception_telephonenumber
    WHERE id=@id AND organization_id=@organization_id;
  ''';

  Map parameters =
    {'full_name'      : fullName,
     'attributes'     : attributes == null ? '{}' : JSON.encode(attributes),
     'extradatauri'   : extradatauri,
     'enabled'        : enabled,
     'id'             : id,
     'organization_id': organizationId,
     'reception_telephonenumber': number};

  return execute(pool, sql, parameters);
}

Future<List<model.Reception>> _getContactReceptions(Pool pool, int contactId) {
  String sql = '''
    SELECT r.id, r.organization_id, r.full_name, r.attributes, r.extradatauri, r.enabled, r.reception_telephonenumber
    FROM reception_contacts rc
      JOIN receptions r on rc.reception_id = r.id
    WHERE rc.contact_id=@contact_id
  ''';

  Map parameters = {'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(
          row.id,
          row.organization_id,
          row.full_name,
          JSON.decode(row.attributes != null ? row.attributes : '{}'),
          row.extradatauri,
          row.enabled,
          row.reception_telephonenumber));
    }
    return receptions;
  });
}
