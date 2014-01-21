part of messageserver.database;

Future<Map> getContactsToMessagesList(List<String> contacts, int receptionId) {
  String sql = '''
    SELECT 
      rcpcon.reception_id, 
      rcpcon.contact_id, 
      rcpcon.wants_messages, 
      rcpcon.attributes, 
      rcpcon.enabled as rcpenabled, 
      con.full_name, 
      con.contact_type, 
      con.enabled
    FROM contacts con join reception_contacts rcpcon on con.id = rcpcon.contact_id
    WHERE rcpcon.reception_id = @receptionId
    ''';

  Map parameters = {'receptionId' : receptionId};

  return database.query(_pool, sql, parameters).then((rows) {
    List contacts = new List();
    for(var row in rows) {
      Map contact =
        {'reception_id'   : row.reception_id,
         'contact_id'     : row.contact_id,
         'wants_messages' : row.wants_messages,
         'attributes'     : JSON.decode(row.attributes),
         'enabled'        : row.enabled && row.rcpenabled,
         'full_name'      : row.full_name,
         'contact_type'   : row.contact_type};
      contacts.add(contact);
    }

    return {'contacts': contacts};
  });
}
