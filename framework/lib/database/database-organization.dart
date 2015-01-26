part of openreception.database;

class Organization implements Storage.Organization {

  static const String className = '${libraryName}.Organization';

  static final Logger log = new Logger(className);

  Connection _connection = null;

  Organization(Connection this._connection);

  Future<Model.Organization> get(int organizationID) {
    final context = '${className}.get';

    String sql = '''
    SELECT id, full_name, billing_type, flag
    FROM organizations
    WHERE id = @id''';

    Map parameters = {'id': organizationID};

    return this._connection.query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        var row = rows.first;
        return new Model.Organization()
          ..id = row.id
          ..fullName = row.full_name
          ..billingType = row.billing_type
          ..flag = row.flag;
      }
    });
  }

  Future<List<Model.Organization>> list() {
    final context = '${className}.list';

    String sql = '''
      SELECT id, full_name, billing_type, flag
      FROM organizations
    ''';

    return this._connection.query(sql).then((rows) {
      List<Model.Organization> organizations = new List<Model.Organization>();
      for(var row in rows) {
        organizations.add(new Model.Organization()
          ..id = row.id
          ..fullName = row.full_name
          ..billingType = row.billing_type
          ..flag = row.flag);
      }

      return organizations;
    });
  }

  Future<Model.Organization> remove(Model.Organization organization) {
    String sql = '''
      DELETE FROM organizations
      WHERE id=@id;
    ''';

    Map parameters = {'id': organization};
    return this._connection.execute(sql, parameters).then((_) => organization);
  }

  Future<Model.Organization> update(Model.Organization organization) {
    String sql = '''
    UPDATE organizations
    SET full_name=@full_name,
        billing_type=@billing_type, 
        flag=@flag
    WHERE id=@id;
  ''';

    Map parameters =
      {'full_name': organization.fullName,
       'billing_type': organization.billingType,
       'flag'     : organization.flag,
       'id'       : organization.id};

    return this._connection.execute(sql, parameters).then((_) => organization);
  }

  Future<Model.Organization> create(Model.Organization organization) {
    final context = '${className}.create';

    String sql = '''
      INSERT INTO organizations (full_name, billing_type, flag)
      VALUES (@full_name, @billing_type, @flag)
      RETURNING id, full_name, billing_type, flag;
    ''';

    Map parameters =
      {'full_name' : organization.fullName,
       'billing_type': organization.billingType,
       'flag': organization.flag};

    return this._connection.query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        var row = rows.first;
        return new Model.Organization()
          ..id = row.id
          ..fullName = row.full_name
          ..billingType = row.billing_type
          ..flag = row.flag;
      }
    });
  }

  @override
  Future<Model.Organization> save(Model.Organization organization) {
    if (organization.id == null || organization.id == Model.Organization.noID) {
      return this.create(organization);
    } else {
      return this.update(organization);
    }
  }
}