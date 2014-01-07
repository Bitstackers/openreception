part of db;

Future<Map> getOrganization(int id) {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
      SELECT id, full_name, uri, attributes, enabled
      FROM organizations
      WHERE id = @id 
    ''';

    Map parameters = {'id' : id};

    conn.query(sql, parameters).toList().then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'id'        : row.id,
           'full_name' : row.full_name,
           'uri'       : row.uri,
           'enabled'   : row.enabled};
        
        Map attributes = JSON.decode(row.attributes);
        attributes.keys
          .where((key) => !data.containsKey(key))
          .forEach((key) => data[key] = attributes[key]);
      }

      completer.complete(data);
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());
  }).catchError((err) => completer.completeError(err));

  return completer.future;
}
