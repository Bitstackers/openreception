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

class Contact implements Storage.Contact {
  /// Database connection.
  final Connection _connection;

  /**
   * Default constructor needs a database [Connection] object in order to
   * function.
   */
  Contact(this._connection);

  /**
   * Add a [Contact] to [Reception] with ID [receptionId].
   */
  Future<Model.Contact> addToReception(
      Model.Contact contact, int receptionId) async {
    String sql = '''
INSERT INTO
  reception_contacts
    (reception_id, contact_id,
     phonenumbers, attributes, enabled, status_email)
VALUES
    (@reception_id, @contact_id,
     @phonenumbers, @attributes, @enabled, @statusEmail)''';

    final Map parameters = {
      'reception_id': receptionId,
      'contact_id': contact.ID,
      'phonenumbers': JSON.encode(contact.phones),
      'attributes': JSON.encode(contact.attributes),
      'enabled': contact.enabled,
      'statusEmail': contact.statusEmail
    };

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.ServerError(
            'Contact with id: ${contact.ID} failed to associate '
            'with reception ${receptionId}');
      }

      contact.receptionID = receptionId;
      return contact;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Remove [Contact] with ID [contactId] from [Reception] with ID [receptionId].
   */
  Future removeFromReception(int contactId, int receptionId) async {
    String sql = '''
DELETE FROM
  reception_contacts
WHERE
  reception_id=@reception_id
AND
  contact_id=@contact_id''';

    final Map parameters = {
      'reception_id': receptionId,
      'contact_id': contactId
    };

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.ServerError(
            'Contact with id: ${contactId} failed to un-associate '
            'with reception ${receptionId}');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Update [Contact] in [Reception] with ID [receptionId].
   */
  Future<Model.Contact> updateInReception(Model.Contact contact) async {
    String sql = '''
UPDATE
  reception_contacts
SET
  attributes=@attributes,
  enabled=@enabled,
  phonenumbers=@phonenumbers,
  status_email=@statusEmail
WHERE
  reception_id=@reception_id
AND
  contact_id=@contact_id''';

    final Map parameters = {
      'reception_id': contact.receptionID,
      'contact_id': contact.ID,
      'phonenumbers': JSON.encode(contact.phones),
      'attributes': JSON.encode(contact.attributes),
      'enabled': contact.enabled,
      'statusEmail': contact.statusEmail
    };

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('Contact not updated');
      }

      return contact;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.BaseContact> get(int contactId) async {
    String sql = '''
SELECT
  id,
  full_name,
  contact_type,
  enabled
FROM
  contacts
WHERE
  id = @contactID''';

    final Map parameters = {'contactID': contactId};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No contact with id: $contactId');
      }

      return _rowToBaseContact(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<List<Model.BaseContact>> list() async {
    String sql = '''
SELECT
  id,
  full_name,
  contact_type,
  enabled
FROM
  contacts''';

    try {
      return (await _connection.query(sql)).map(_rowToBaseContact);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Create a new [Model.BaseContact].
   */
  Future<Model.BaseContact> create(Model.BaseContact contact) async {
    String sql = '''
INSERT INTO
  contacts
    (full_name, contact_type, enabled)
VALUES
    (@full_name, @contact_type, @enabled)
RETURNING
  id;''';

    final Map parameters = {
      'full_name': contact.fullName,
      'contact_type': contact.contactType,
      'enabled': contact.enabled
    };

    try {
      final rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.ServerError('Contact not created');
      }

      contact.id = rows.first.id;
      return contact;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Iterable<Model.PhoneNumber>> phones(
      int contactId, int receptionId) async {
    String sql = '''
SELECT
  phonenumbers
FROM
  reception_contacts
WHERE
  contact_id = @contactID
AND
  reception_id = @receptionID''';

    final Map parameters = {'contactID': contactId, 'receptionID': receptionId};

    try {
      final Iterable rows = await _connection.query(sql, parameters);
      if (rows.isEmpty) {
        throw new Storage.NotFound('No contact found with ID $contactId'
            ' in reception with ID $receptionId');
      }

      final Iterable<Map> phonesMap = rows.first.phonenumbers;

      return phonesMap.map(_mapToPhone);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Iterable<Model.Contact>> listByReception(int receptionId) async {
    final String sql = '''
SELECT
  rcpcon.reception_id,
  rcpcon.contact_id,
  rcpcon.attributes,
  rcpcon.enabled AND con.enabled as enabled,
  con.full_name,
  con.contact_type,
  rcpcon.phonenumbers as phone,
  rcpcon.status_email as status_email
FROM
  contacts con
JOIN
  reception_contacts rcpcon
ON
  con.id = rcpcon.contact_id
WHERE
  rcpcon.reception_id = @receptionid''';

    final Map parameters = {'receptionid': receptionId};

    try {
      return (await _connection.query(sql, parameters)).map(_rowToContact);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   *
   */
  Future<Model.Contact> getByReception(int receptionId, int contactId) async {
    String sql = '''
SELECT
  rcpcon.reception_id,
  rcpcon.contact_id,
  rcpcon.attributes,
  rcpcon.enabled AND con.enabled as enabled,
  con.full_name,
  con.contact_type,
  con.enabled as conenabled,
  rcpcon.phonenumbers as phone,
  rcpcon.status_email as status_email
FROM
  contacts con
JOIN
  reception_contacts rcpcon
ON
  con.id = rcpcon.contact_id
WHERE
  rcpcon.reception_id = @receptionid
AND
  rcpcon.contact_id = @contactid''';

    final Map parameters = {'receptionid': receptionId, 'contactid': contactId};

    try {
      Iterable rows = await _connection.query(sql, parameters);

      if (rows.isEmpty) {
        throw new Storage.NotFound('No contact with id: $contactId');
      }

      return _rowToContact(rows.first);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve all contacts from an organization.
   */
  Future<Iterable<Model.BaseContact>> organizationContacts(
      int organizationId) async {
    String sql = '''
SELECT DISTINCT
  c.id,
  c.full_name,
  c.enabled,
  c.contact_type
FROM
  receptions r
JOIN
  reception_contacts rc
ON
  r.id = rc.reception_id
JOIN
  contacts c
ON
  rc.contact_id = c.id
WHERE
  r.organization_id=@organization_id
ORDER BY
  c.id''';

    final Map parameters = {'organization_id': organizationId};

    try {
      return (await _connection.query(sql, parameters)).map(_rowToBaseContact);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve all organizations id's of a contact.
   */
  Future<Iterable<int>> organizations(int contactID) async {
    String sql = '''
SELECT DISTINCT
  organization_id
FROM
  reception_contacts
JOIN
  receptions
ON
  receptions.id = reception_contacts.reception_id
WHERE
  reception_contacts.contact_id = @contactID''';

    final Map parameters = {'contactID': contactID};

    try {
      return (await _connection.query(sql, parameters))
          .map((var row) => row.organization_id as int);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Retrieve all reception id's of a contact.
   */
  Future<Iterable<int>> receptions(int contactID) async {
    String sql = '''
SELECT
  reception_id
FROM
  reception_contacts
WHERE
  contact_id=@contactID''';

    final Map parameters = {'contactID': contactID};

    try {
      return (await _connection.query(sql, parameters))
          .map((var row) => row.reception_id as int);
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Removes a contact from the database.
   */
  Future remove(int contactID) async {
    String sql = '''
      DELETE FROM contacts
      WHERE id=@id;
    ''';

    final Map parameters = {'id': contactID};

    try {
      final int rowsAffected = await _connection.execute(sql, parameters);

      if (rowsAffected == 0) {
        throw new Storage.NotFound('No contact with id: $contactID');
      }
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }

  /**
   * Update a [Contact] in the database.
   */
  Future<Model.BaseContact> update(Model.BaseContact contact) async {
    String sql = '''
UPDATE
  contacts
SET
  full_name=@full_name,
  contact_type=@contact_type,
  enabled=@enabled
WHERE
  id=@id''';

    final Map parameters = {
      'full_name': contact.fullName,
      'contact_type': contact.contactType,
      'enabled': contact.enabled,
      'id': contact.id
    };

    try {
      final affectedRows = await _connection.execute(sql, parameters);

      if (affectedRows == 0) {
        throw new Storage.ServerError('BaseContact not updated');
      }

      return contact;
    } on Storage.SqlError catch (error) {
      throw new Storage.ServerError(error.toString());
    }
  }
}
