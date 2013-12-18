part of db;

Future<Map> getOrganizationList() {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
      SELECT id, full_name, uri, enabled
      FROM organizations
    ''';

    conn.query(sql).toList().then((rows) {
      List organizations = new List();
      for(var row in rows) {
        Map organization =
          {'organization_id' : row.id,
           'full_name'       : row.full_name,
           'uri'             : row.uri,
           'enabled'         : row.enabled};
        organizations.add(organization);
      }

      Map data = {'organizations': organizations};

      completer.complete(data);
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());
  }).catchError((err) => completer.completeError(err));

  return completer.future;
}
