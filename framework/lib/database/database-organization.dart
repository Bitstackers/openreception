part of openreception.database;

class Organization implements Storage.Organization {
  static const String className = '${libraryName}.Organization';

  static final Logger log = new Logger(className);

  Connection _connection = null;

  /**
   * Constructor.
   */
  Organization(Connection this._connection);

  /**
   *
   */
  Future<Iterable<Model.BaseContact>> contacts(int organizationID) {
    String sql = '''
SELECT DISTINCT
  contacts.id AS id, 
  contacts.full_name as full_name,
  contacts.contact_type as contact_type,
  contacts.enabled AS enabled
FROM 
  receptions
JOIN 
  reception_contacts
ON 
  reception_contacts.reception_id = receptions.id
JOIN 
  contacts 
ON 
  reception_contacts.contact_id = contacts.id
WHERE 
  organization_id=@organization_id
  ''';

    Map parameters = {'organization_id': organizationID};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.map(_rowToReception))
        .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters');
      return new Future.error(error, stackTrace);
    });
  }

  /**
   *
   */
  Future<Iterable<Model.Reception>> receptions(int organizationID) {
    String sql = '''
    SELECT id, organization_id, full_name, 
           attributes, extradatauri, 
           enabled, reception_telephonenumber
    FROM receptions
    WHERE organization_id=@organization_id
  ''';

    Map parameters = {'organization_id': organizationID};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.map(_rowToReception))
        .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters');
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Retrieve a single organization identified by [organizationID] from
   * database.
   */
  Future<Model.Organization> get(int organizationID) {
    String sql = '''
    SELECT id, full_name, billing_type, flag
    FROM organizations
    WHERE id = @id
  ''';

    Map parameters = {'id': organizationID};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.length == 1
            ? _rowToOrganization(rows.first)
            : new Future.error(new Storage.NotFound('oid:$organizationID')))
        .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters');
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Retrieve the current list of organizations from database.
   */
  Future<Iterable<Model.Organization>> list() {
    String sql = '''
    SELECT id, full_name, billing_type, flag
    FROM organizations
  ''';

    return _connection
        .query(sql)
        .then((Iterable rows) => rows.map(_rowToOrganization))
        .catchError((error, stackTrace) {
      log.severe('sql:$sql');
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Create a new organization in the database.
   */
  Future<Model.Organization> create(Model.Organization organization) {
    String sql = '''
    INSERT INTO organizations (full_name, billing_type, flag)
    VALUES (@full_name, @billing_type, @flag)
    RETURNING id;
  ''';

    Map parameters = {
      'full_name': organization.fullName,
      'billing_type': organization.billingType,
      'flag': organization.flag
    };

    return _connection.query(sql, parameters).then(
        (Iterable rows) => rows.length == 1
            ? (organization
      ..id = rows.first.id)
        : new Future.error(
                new Storage.ServerError('Failed to create new organization'))
            .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters');
      return new Future.error(error, stackTrace);
    }));
  }

  /**
   * Update an existing organization in the database.
   */
  Future<Model.Organization> update(Model.Organization organization) {
    String sql = '''
    UPDATE organizations
    SET full_name=@full_name,
        billing_type=@billing_type,
        flag=@flag
    WHERE id=@id;
  ''';

    Map parameters = {
      'full_name': organization.fullName,
      'billing_type': organization.billingType,
      'flag': organization.flag,
      'id': organization.id
    };

    return _connection.execute(sql, parameters);
  }

  /**
   * Delete an existing organization in the database.
   */
  Future remove(int organizationID) {
    String sql = '''
    DELETE FROM organizations
    WHERE id=@id;
  ''';

    Map parameters = {'id': organizationID};
    return _connection
        .execute(sql, parameters)
        .then((int rowsAffected) => rowsAffected != 1
            ? new Future.error(
                new Storage.NotFound('Failed to create new organization'))
            : null)
        .catchError((error, stackTrace) {
      log.severe('sql:$sql :: parameters:$parameters');
      return new Future.error(error, stackTrace);
    });
  }
}
