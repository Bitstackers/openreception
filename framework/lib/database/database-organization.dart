/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.database;

class Organization implements Storage.Organization {
  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  Organization(Connection this._connection);

  /**
   *
   */
  Future<Iterable<Model.BaseContact>> contacts(int organizationId) async {
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

    final Map parameters = {'organization_id': organizationId};

    try {
      return (await _connection.query(sql, parameters)).map(_rowToBaseContact);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Iterable<int>> receptions(int organizationId) async {
    String sql = '''
SELECT
  id
FROM
  receptions
WHERE
  organization_id = @organization_id''';

    final Map parameters = {'organization_id': organizationId};

    try {
      return (await _connection.query(sql, parameters))
          .map((row) => row.id as int);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve a single organization identified by [organizationId] from
   * database.
   */
  Future<Model.Organization> get(int organizationId) async {
    String sql = '''
SELECT
  id,
  full_name,
  billing_type,
  flag
FROM
  organizations
WHERE
  id = @id''';

    final Map parameters = {'id': organizationId};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No organization with id: $organizationId');
      }

      return _rowToOrganization(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve the current list of organizations from database.
   */
  Future<Iterable<Model.Organization>> list() async {
    String sql = '''
SELECT
  id,
  full_name,
  billing_type,
  flag
FROM
  organizations''';

    try {
      return (await _connection.query(sql)).map(_rowToOrganization);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Create a new organization in the database.
   */
  Future<Model.Organization> create(Model.Organization organization) async {
    String sql = '''
INSERT INTO
  organizations
    (full_name, billing_type, flag)
VALUES
    (@full_name, @billing_type, @flag)
RETURNING
  id''';

    final Map parameters = {
      'full_name': organization.fullName,
      'billing_type': organization.billingType,
      'flag': organization.flag
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('Failed to create new organization');
      }

      organization.id = rows.first.id;
      return organization;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Update an existing organization in the database.
   */
  Future<Model.Organization> update(Model.Organization organization) async {
    String sql = '''
UPDATE
  organizations
SET
  full_name = @full_name,
  billing_type = @billing_type,
  flag = @flag
WHERE
  id = @id''';

    final Map parameters = {
      'full_name': organization.fullName,
      'billing_type': organization.billingType,
      'flag': organization.flag,
      'id': organization.id
    };

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('Organization not updated');
      }

      return organization;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Delete an existing organization in the database.
   */
  @override
  Future remove(int organizationID) async {
    String sql = '''
DELETE FROM
  organizations
WHERE
  id = @id''';

    final Map parameters = {'id': organizationID};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No organization with id: $organizationID');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
