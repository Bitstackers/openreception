part of adaheads.server.database;

Future<model.Organization> _getOrganization(ORDatabase.Connection connection, int organizationId) {
  String sql = '''
    SELECT id, full_name, billing_type, flag
    FROM organizations
    WHERE id = @id
  ''';

  Map parameters = {'id': organizationId};

  return connection.query(sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      var row = rows.first;
      return new model.Organization(row.id, row.full_name, row.billing_type, row.flag);
    }
  });
}

Future<List<model.Organization>> _getOrganizationList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT id, full_name, billing_type, flag
    FROM organizations
  ''';

  return connection.query(sql).then((List rows) {
    List<model.Organization> organizations = new List<model.Organization>();
    for(var row in rows) {
      organizations.add(new model.Organization(row.id, row.full_name, row.billing_type, row.flag));
    }

    return organizations;
  });
}

Future<int> _createOrganization(ORDatabase.Connection connection, String fullName, String billingType, String flag) {
  String sql = '''
    INSERT INTO organizations (full_name, billing_type, flag)
    VALUES (@full_name, @billing_type, @flag)
    RETURNING id;
  ''';

  Map parameters =
    {'full_name' : fullName,
     'billing_type': billingType,
     'flag': flag};

  return connection.query(sql, parameters).then((rows) => rows.first.id);
}

Future<int> _updateOrganization(ORDatabase.Connection connection, int organizationId, String fullName, String billingType, String flag) {
  String sql = '''
    UPDATE organizations
    SET full_name=@full_name,
        billing_type=@billing_type, 
        flag=@flag
    WHERE id=@id;
  ''';

  Map parameters =
    {'full_name': fullName,
     'billing_type': billingType,
     'flag'     : flag,
     'id'       : organizationId};

  return connection.execute(sql, parameters);
}

Future<int> _deleteOrganization(ORDatabase.Connection connection, int organizationId) {
  String sql = '''
    DELETE FROM organizations
    WHERE id=@id;
  ''';

  Map parameters = {'id': organizationId};
  return connection.execute(sql, parameters);
}
