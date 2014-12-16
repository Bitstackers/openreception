part of receptionserver.database;

Future<Map> getReceptionList() {

  String sql = '''
    SELECT id, full_name, enabled, attributes, reception_telephonenumber, last_check
    FROM receptions
  ''';

  return connection.query(sql).then((rows) {
    List receptions = new List();
    for(var row in rows) {
      Map reception =
        {'reception_id' : row.id,
         'full_name'    : row.full_name,
         'enabled'      : row.enabled,
         'reception_telephonenumber': row.reception_telephonenumber,
         'last_check'   : row.last_check.toString()};

      if (row.attributes != null) {
        Map attributes = row.attributes;
        if(attributes != null) {
          attributes.forEach((key, value) => reception.putIfAbsent(key, () => value));
        }
      }
      receptions.add(reception);
    }

    return {'reception_list':receptions};
  });
}
