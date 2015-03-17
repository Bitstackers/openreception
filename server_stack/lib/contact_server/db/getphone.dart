part of contactserver.database;

Future<Map> getPhone(int contactId, int receptionId, int phoneId) {
  String sql = '''
    SELECT id, kind, value
    FROM phone_numbers p JOIN contact_phone_numbers c ON p.id = c.phone_number_id
    WHERE c.phone_number_id = @phoneId AND c.contact_id = @contactId AND c.reception_id = @receptionId''';

  Map parameters =
    {'phoneId': phoneId,
     'contactId': contactId,
     'receptionId': receptionId};

  return connection.query(sql, parameters).then((rows) {
    Map data = {};
    if(rows.length == 1) {
      var row = rows.first;
      data =
        {'id'   : row.id,
         'type' : row.kind,
         'value': row.value};
    }

    return data;
  });
}