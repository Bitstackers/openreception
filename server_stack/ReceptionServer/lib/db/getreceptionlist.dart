part of receptionserver.database;

Future<Map> getReceptionList() {
  
  String sql = '''
    SELECT id, full_name, enabled, attributes
    FROM receptions
  ''';
  
  return database.query(_pool, sql).then((rows) {
    List receptions = new List();
    for(var row in rows) {
      Map reception =
        {'reception_id' : row.id,
         'full_name'    : row.full_name,
         'enabled'      : row.enabled};

      if (row.attributes != null) {
        Map attributes = JSON.decode(row.attributes);
        if(attributes != null) {
          attributes.forEach((key, value) => reception.putIfAbsent(key, () => value));
        }
      }
      receptions.add(reception);
    }
    
    return {'reception_list':receptions};
  });
}
