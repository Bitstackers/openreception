part of db;

Future<Map> createOrganization(String full_name, String uri, Map attributes, bool enabled) {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
      INSERT INTO organizations (full_name, uri, attributes, enabled)
      VALUES (@full_name, @uri, @attributes, @enabled);
    ''';

    Map parameters =
      {'full_name' : full_name,
       'uri'       : uri,
       'attributes': JSON.encode(attributes),
       'enabled'   : enabled};

    conn.execute(sql, parameters).then((rowsAffected) {
      completer.complete({'rowsAffected': rowsAffected});
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());

  }).catchError((err) => completer.completeError(err));

  return completer.future;
}
