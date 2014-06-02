part of adaheads.server.database;

//Future<int> _createPhoneNumber(Pool pool, int receptionId, int contactId, String value, String kind) {
//  String sql = '''
//  WITH newphone AS (
//     INSERT INTO phone_numbers (value, kind)
//     VALUES (@phonevalue, @phonekind)
//     RETURNING id
//  )
//  INSERT INTO contact_phone_numbers (reception_id, contact_id, phone_number_id)
//  SELECT 1, 1, id
//  FROM newphone
//  RETURNING phone_number_id
//  ''';
//
//  Map parameters = {'phonevalue'   : value,
//                    'phonekind'    : kind,
//                    'reception_id' : receptionId,
//                    'contact_id'   : contactId};
//
//  return query(pool, sql, parameters).then((rows) {
//    if(rows.length != 1) {
//      return null;
//    } else {
//      Row row = rows.first;
//      return row.id;
//    }
//  });
//}

//Future<int> _deletePhoneNumber(Pool pool, int phonenumberId) {
//  String sql = '''
//      DELETE FROM phone_numbers
//      WHERE id=@id;
//    ''';
//
//  Map parameters = {'id': phonenumberId};
//  return execute(pool, sql, parameters);
//}

//Future<List<model.Phone>> _getPhoneNumbers(Pool pool, int receptionId, int contactId) {
//  String sql = '''
//  SELECT id, value, kind
//  FROM contact_phone_numbers
//    JOIN phone_numbers ON id = phone_number_id
//  WHERE contact_id = @contact_id AND reception_id = @reception_id
//  ''';
//
//  Map parameters = {'reception_id' : receptionId,
//                    'contact_id'   : contactId};
//
//  return query(pool, sql, parameters).then((rows) {
//    List<model.Phone> phonenumbers = new List<model.Phone>();
//    for(var row in rows) {
//      phonenumbers.add(new model.Phone(row.id, row.value, row.kind));
//    }
//    return phonenumbers;
//  });
//}
