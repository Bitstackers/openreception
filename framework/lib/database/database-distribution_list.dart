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

class DistributionList implements Storage.DistributionList {
  static const String className = '${libraryName}.DistributionList';

  static final Logger log = new Logger(className);

  final Connection _connection;

  DistributionList(this._connection);

  Future<Model.DistributionList> list(int receptionId, int contactId) {
    String sql = '''
SELECT
  dl.id                  AS id,
  dl.role                AS role,
  recipient_reception_id AS recipient_reception_id,
  reception.full_name    AS recipient_reception_name,
  contact.full_name      AS recipient_contact_name,
  recipient_contact_id   AS recipient_contact_id
FROM 
  distribution_list dl 
JOIN 
  receptions reception 
ON 
  (recipient_reception_id = reception.id)
JOIN 
  contacts contact 
ON 
  (recipient_contact_id = contact.id) 
WHERE 
  owner_reception_id = @reception_id 
AND 
  owner_contact_id = @contact_id;
''';

    Map parameters = {'reception_id': receptionId, 'contact_id': contactId};

    return _connection.query(sql, parameters).then((rows) {
      Model.DistributionList list = new Model.DistributionList.empty();
      for (var row in rows) {
        Model.MessageRecipient recipient = new Model.MessageRecipient()
          ..receptionID = row.recipient_reception_id
          ..receptionName = row.recipient_reception_name
          ..contactID = row.recipient_contact_id
          ..contactName = row.recipient_contact_name
          ..role = row.role
          ..id = row.id;

        list.add(recipient);
      }
      return list;
    });
  }

  Future<Model.MessageRecipient> addRecipient(int ownerReceptionId, int ownerContactId,
      Model.MessageRecipient recipient) {
    String sql = '''
INSERT INTO 
  distribution_list 
    (owner_reception_id, owner_contact_id, role, 
     recipient_reception_id, recipient_contact_id)
VALUES 
    (@owner_reception, @owner_contact, @role, 
     @recipient_reception, @recipient_contact)
RETURNING id;''';

    Map parameters = {
      'owner_reception': ownerReceptionId,
      'owner_contact': ownerContactId,
      'role': recipient.role,
      'recipient_reception': recipient.receptionID,
      'recipient_contact': recipient.contactID
    };

    return _connection
        .query(sql, parameters)
        .then((rows) => recipient..id = rows.first.id);
  }

  Future removeRecipient(int entryId) {
    String sql = '''
DELETE FROM 
  distribution_list
WHERE 
  id=@id;''';

    Map parameters = {'id': entryId};
    return _connection.execute(sql, parameters);
  }
}
