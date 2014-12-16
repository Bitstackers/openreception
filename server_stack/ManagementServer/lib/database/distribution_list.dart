part of adaheads.server.database;

Future<model.DistributionList> _getDistributionList(ORDatabase.Connection connection, int receptionId, int contactId) {
  String sql = '''
    SELECT owner_reception_id, owner_contact_id, role, recipient_reception_id, recipient_contact_id, id
    FROM distribution_list
    WHERE owner_reception_id = @reception_id AND owner_contact_id = @contact_id;
  ''';

  Map parameters =
    {'reception_id': receptionId,
     'contact_id': contactId};

  return connection.query(sql, parameters).then((rows) {
    model.DistributionList list = new model.DistributionList();
    for(var row in rows) {
      model.DistributionListEntry contact = new model.DistributionListEntry()
        ..receptionId = row.recipient_reception_id
        ..contactId = row.recipient_contact_id
        ..id = row.id;

      if(row.role == 'to') {
        list.to.add(contact);
      } else if(row.role == 'cc') {
        list.cc.add(contact);
      } else if(row.role == 'bcc') {
        list.bcc.add(contact);
      }
    }
    return list;
  });
}

Future<int> _createDistributionListEntry(ORDatabase.Connection connection, int ownerReceptionId, int ownerContactId, String role, int recipientReceptionId, int recipientContactId) {
  String sql = '''
    INSERT INTO distribution_list (owner_reception_id, owner_contact_id, role, recipient_reception_id, recipient_contact_id)
    VALUES (@owner_reception, @owner_contact, @role, @recipient_reception, @recipient_contact)
    RETURNING id;
  ''';

  Map parameters =
    {'owner_reception'     : ownerReceptionId,
     'owner_contact'       : ownerContactId,
     'role'                : role,
     'recipient_reception' : recipientReceptionId,
     'recipient_contact'   : recipientContactId};

  return connection.query(sql, parameters).then((rows) => rows.first.id);
}

Future _deleteDistributionListEntry(ORDatabase.Connection connection, int entryId) {
  String sql = '''
      DELETE FROM distribution_list
      WHERE id=@id;
    ''';

  Map parameters = {'id': entryId};
  return connection.execute(sql, parameters);
}
