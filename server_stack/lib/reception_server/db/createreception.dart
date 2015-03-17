part of receptionserver.database;

Future<Map> createReception(String full_name, Map attributes, bool enabled) {
  String sql = '''
    INSERT INTO receptions (full_name, attributes, enabled)
    VALUES (@full_name, @attributes, @enabled)
    RETURNING id;
  ''';

  Map parameters =
    {'full_name' : full_name,
     'attributes': attributes == null ? '{}' : attributes,
     'enabled'   : enabled};

  return connection.query(sql, parameters).then((rows) {
    Map data = {};
    if (rows.length == 1) {
      data = {'id': rows.first.id};
    }
    return data;
  });
}
