part of db;

Future<Map> deleteOrganization(int id) {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
      DELETE FROM organizations
      WHERE id = @id;
    ''';

    Map parameters = {'id' : id};

    conn.execute(sql, parameters).then((rowsAffected) {
      completer.complete({'rowsAffected': rowsAffected});
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());

  }).catchError((err) => completer.completeError(err));

  return completer.future;
}
