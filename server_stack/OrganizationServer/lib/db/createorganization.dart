part of db;

Future<Map> createOrganization(String full_name, String uri, Map attributes, bool enabled) {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
      INSERT INTO organizations (full_name, uri, attributes, enabled)
      VALUES (@full_name, @uri, @attributes, @enabled)
      RETURNING id;
    ''';

    Map parameters =
      {'full_name' : full_name,
       'uri'       : uri,
       'attributes': JSON.encode(attributes),
       'enabled'   : enabled};

    conn.query(sql, parameters).toList().then((rows) {
      Map data = {};
      if (rows.length == 1) {
        data = {'id': rows.first.id};
      }
      completer.complete(data);
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());

  }).catchError((err) => completer.completeError(err));

  return completer.future;
}
