part of organizationserver.database;

Future<Map> createOrganization(String full_name, String uri, Map attributes, bool enabled) {
  String sql = '''
    INSERT INTO organizations (full_name, uri, attributes, enabled)
    VALUES (@full_name, @uri, @attributes, @enabled)
    RETURNING id;
  ''';

  Map parameters =
    {'full_name' : full_name,
     'uri'       : uri,
     'attributes': attributes == null ? '{}' : JSON.encode(attributes),
     'enabled'   : enabled};

  return database.query(_pool, sql, parameters).then((rows) {
    Map data = {};
    if (rows.length == 1) {
      data = {'id': rows.first.id};
    }
    return data;
  });
}
