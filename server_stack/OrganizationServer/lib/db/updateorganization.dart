part of organizationserver.database;

Future<Map> updateOrganization(int id, String full_name, String uri, Map attributes, bool enabled) {
  return _pool.connect().then((Connection conn) {
    String sql = '''
      UPDATE organizations
      SET full_name=@full_name, uri=@uri, attributes=@attributes, enabled=@enabled
      WHERE id=@id;
    ''';

    Map parameters =
      {'id'        : id,
       'full_name' : full_name,
       'uri'       : uri,
       'attributes': attributes == null ? '{}' : JSON.encode(attributes),
       'enabled'   : enabled};

    return conn.execute(sql, parameters).then((rowsAffected) {
      return {'rowsAffected': rowsAffected};
    }).whenComplete(() => conn.close());
  });
}
