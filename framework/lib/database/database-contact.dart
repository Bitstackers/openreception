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
  static final Logger log = new Logger('$libraryName.Contact');

  final Connection _connection;

  Contact(this._connection);

  Future<Model.Contact> addToReception(Model.Contact contact, int receptionID) {
    String sql = '''
    INSERT INTO
      reception_contacts
        (reception_id, contact_id, wants_messages,
         phonenumbers, attributes, enabled, status_email)
    VALUES
        (@reception_id, @contact_id, @wants_messages,
         @phonenumbers, @attributes, @enabled, @statusEmail);
  ''';

    Map parameters = {
      'reception_id': receptionID,
      'contact_id': contact.ID,
      'wants_messages': contact.wantsMessage,
      'phonenumbers': JSON.encode(contact.phones),
      'attributes': JSON.encode(contact.attributes),
      'enabled': contact.enabled,
      'statusEmail': contact.statusEmail
    };

    return _connection
        .execute(sql, parameters)
        .then((int affectedRows) => affectedRows == 1
            ? (contact..receptionID = receptionID)
            : new Future.error(new StateError('No association was created!')))
        .catchError((error, stackTrace) {
      log.severe('SQL: $sql :: Parameters : $parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  Future<Model.Contact> removeFromReception(int contactId, int receptionId) {
    String sql = '''
    DELETE FROM reception_contacts
    WHERE reception_id=@reception_id AND contact_id=@contact_id;
  ''';

    Map parameters = {'reception_id': receptionId, 'contact_id': contactId};
    return _connection.execute(sql, parameters);
  }

  Future<Model.Contact> updateInReception(Model.Contact contact) {
    String sql = '''
    UPDATE reception_contacts
    SET wants_messages=@wants_messages,
        attributes=@attributes,
        enabled=@enabled,
        phonenumbers=@phonenumbers,
        status_email=@statusEmail
    WHERE reception_id=@reception_id AND contact_id=@contact_id;
  ''';

    Map parameters = {
      'reception_id': contact.receptionID,
      'contact_id': contact.ID,
      'wants_messages': contact.wantsMessage,
      'phonenumbers': JSON.encode(contact.phones),
      'attributes': JSON.encode(contact.attributes),
      'enabled': contact.enabled,
      'statusEmail': contact.statusEmail
    };

    return _connection
        .execute(sql, parameters)
        .then((int affectedRows) => affectedRows == 1
            ? contact
            : new Future.error(new StateError('No association was updated!')))
        .catchError((error, stackTrace) {
      log.severe('SQL: $sql :: Parameters : $parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  Future<Model.BaseContact> get(int contactID) {
    String sql = '''
    SELECT id, full_name, contact_type, enabled
    FROM contacts
    WHERE id = @contactID ''';

    Map parameters = {'contactID': contactID};

    return _connection.query(sql, parameters).then((Iterable rows) {
      if (rows.isEmpty) {
        throw new Storage.NotFound('No contact found with ID $contactID');
      }

      return _rowToBaseContact(rows.first);
    });
  }

  Future<List<Model.BaseContact>> list() {
    String sql = '''
    SELECT id, full_name, contact_type, enabled
    FROM contacts
  ''';

    return _connection
        .query(sql)
        .then((Iterable rows) => rows.map(_rowToBaseContact));
  }

  /**
   * Create a new [Model.BaseContact].
   */
  Future<Model.BaseContact> create(Model.BaseContact contact) {
    String sql = '''
    INSERT INTO contacts (full_name, contact_type, enabled)
    VALUES (@full_name, @contact_type, @enabled)
    RETURNING id;
  ''';

    Map parameters = {
      'full_name': contact.fullName,
      'contact_type': contact.contactType,
      'enabled': contact.enabled
    };

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.length > 0
            ? (contact..id = rows.first.id)
            : new Future.error(new StateError('No contact was created!')))
        .catchError((error, stackTrace) {
      log.severe('SQL: $sql :: Parameters : $parameters', error, stackTrace);

      return new Future.error(error, stackTrace);
    });
  }

  Future<Iterable<Model.PhoneNumber>> phones(int contactID, int receptionID) {
    String sql = '''
        SELECT phonenumbers
        FROM reception_contacts
        WHERE contact_id = @contactID AND reception_id = @receptionID''';

    Map parameters = {'contactID': contactID, 'receptionID': receptionID};

    return _connection.query(sql, parameters).then((rows) {
      if ((rows as Iterable).isEmpty) {
        throw new Storage.NotFound('No contact found with ID $contactID'
            ' in reception with ID $receptionID');
      }

      Iterable<Map> phonesMap = (rows as Iterable).first.phonenumbers;

      return phonesMap.map(_mapToPhone);
    });
  }

  @deprecated
  Future<Iterable<Model.MessageEndpoint>> endpoints(
      int contactID, int receptionID) {
    String sql = '''
        SELECT address, address_type, confidential, enabled, priority,
              description
        FROM messaging_end_points
        WHERE contact_id = @contactID AND reception_id = @receptionID''';

    Map parameters = {'contactID': contactID, 'receptionID': receptionID};

    return _connection.query(sql, parameters).then((rows) =>
        (rows as Iterable).map((row) => new Model.MessageEndpoint.empty()
          ..address = row.address
          ..type = row.address_type
          ..confidential = row.confidential
          ..enabled = row.enabled
          //..priority = row.priority,
          ..description = row.description));
  }

  Future<Iterable<Model.Contact>> listByReception(int receptionId) {
    String sql = '''
    SELECT rcpcon.reception_id,
           rcpcon.contact_id,
           rcpcon.wants_messages,
           rcpcon.attributes,
           rcpcon.enabled as rcpenabled,
           con.full_name,
           con.contact_type,
           con.enabled as conenabled,
           rcpcon.phonenumbers as phone,
           rcpcon.status_email as status_email
    FROM contacts con
      JOIN reception_contacts rcpcon on con.id = rcpcon.contact_id
    WHERE rcpcon.reception_id = @receptionid''';

    Map parameters = {'receptionid': receptionId};

    return _connection
        .query(sql, parameters)
        .then((rows) => (rows as Iterable).map(_rowToContact));
  }

  Future<Model.Contact> getByReception(int receptionId, int contactId) {
    String sql = '''
      SELECT rcpcon.reception_id,
             rcpcon.contact_id,
             rcpcon.wants_messages,
             rcpcon.attributes,
             rcpcon.enabled as rcpenabled,
             con.full_name,
             con.contact_type,
             con.enabled as conenabled,
             rcpcon.phonenumbers as phone,
             rcpcon.status_email as status_email

          FROM   contacts con
            JOIN reception_contacts rcpcon on con.id = rcpcon.contact_id
          WHERE  rcpcon.reception_id = @receptionid
             AND rcpcon.contact_id = @contactid ;''';

    Map parameters = {'receptionid': receptionId, 'contactid': contactId};

    return _connection.query(sql, parameters).then((rows) {
      if (rows != null && rows.length == 1) {
        return (_rowToContact(rows.first));
      } else {
        throw new Storage.NotFound(
            'ContactID: $contactId, ReceptionID: $receptionId');
      }
    }).catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe(error, stackTrace);
      }
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Retrieve all contacts from an organization.
   */
  Future<Iterable<Model.BaseContact>> organizationContacts(int organizationId) {
    String sql = '''
    SELECT DISTINCT c.id, c.full_name, c.enabled, c.contact_type
    FROM receptions r
      JOIN reception_contacts rc on r.id = rc.reception_id
      JOIN contacts c on rc.contact_id = c.id
    WHERE r.organization_id = @organization_id
    ORDER BY c.id
  ''';

    Map parameters = {'organization_id': organizationId};

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.map(_rowToBaseContact));
  }

  /**
   * Retrieve all organizations id's of a contact.
   */
  Future<Iterable<int>> organizations(int contactID) {
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
  reception_contacts.contact_id =@contactID''';

    Map parameters = {'contactID': contactID};

    return _connection.query(sql, parameters).then(
        (rows) => (rows as Iterable).map((var row) => row.organization_id));
  }

  /**
   * Retrieve all reception id's of a contact.
   */
  Future<Iterable<int>> receptions(int contactID) {
    String sql = '''

    SELECT reception_id
        FROM reception_contacts
      WHERE
      contact_id  =@contactID''';

    Map parameters = {'contactID': contactID};

    return _connection
        .query(sql, parameters)
        .then((rows) => (rows as Iterable).map((var row) => row.reception_id));
  }

  /**
   * Removes a contact from the database.
   */
  Future remove(int contactID) {
    String sql = '''
      DELETE FROM contacts
      WHERE id=@id;
    ''';

    Map parameters = {'id': contactID};
    return _connection.execute(sql, parameters).then((int rowsAffected) =>
        rowsAffected > 0
            ? null
            : new Future.error(new Storage.NotFound('$contactID')));
  }

  Future<Model.BaseContact> update(Model.BaseContact contact) {
    String sql = '''
    UPDATE contacts
    SET full_name=@full_name, contact_type=@contact_type, enabled=@enabled
    WHERE id=@id;
  ''';

    Map parameters = {
      'full_name': contact.fullName,
      'contact_type': contact.contactType,
      'enabled': contact.enabled,
      'id': contact.id
    };

    return _connection.execute(sql, parameters).then((int rowsAffected) =>
        rowsAffected > 0
            ? contact
            : new Future.error(new Storage.NotFound('en')));
  }
}
