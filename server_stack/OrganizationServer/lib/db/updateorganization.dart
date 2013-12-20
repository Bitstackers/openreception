part of db;

Future<Map> updateOrganization(int id, String full_name, String uri, Map attributes, bool enabled) {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
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

    conn.execute(sql, parameters).then((rowsAffected) {
      completer.complete({'rowsAffected': rowsAffected});
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());

  }).catchError((err) => completer.completeError(err));

  return completer.future;
}
