part of receptionserver.database;

Future<Map> updateReception(int id, String full_name, String uri, Map attributes, bool enabled) {
    String sql = '''
      UPDATE receptions
      SET full_name=@full_name, uri=@uri, attributes=@attributes, enabled=@enabled
      WHERE id=@id;''';

    Map parameters =
      {'id'        : id,
       'full_name' : full_name,
       'uri'       : uri,
       'attributes': attributes == null ? '{}' : attributes,
       'enabled'   : enabled};
    return connection.execute(sql, parameters).then((rowsAffected) {
      return {'rowsAffected': rowsAffected};
    });
}
