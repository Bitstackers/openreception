part of contactserver.database;

Future<Map> getContactsPhones(int receptionId, int contactId) {
  String sql = '''
    SELECT pn.id, pn.value, pn.kind
    FROM contact_phone_numbers cpn
      JOIN phone_numbers pn on cpn.phone_number_id = pn.id
    WHERE cpn.reception_id = @receptionId AND cpn.contact_id = @contactId''';

  Map parameters = 
    {'contactId': contactId,
     'receptionId': receptionId};

  return database.query(_pool, sql, parameters).then((rows) {
    List phones = [];
    for(var row in rows) {
      Map data = 
        {'id': row.id,
         'value': row.value,
         'type': row.kind};
    }

    return {'phones': phones};
  });
}