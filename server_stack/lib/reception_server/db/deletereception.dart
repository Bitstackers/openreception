part of receptionserver.database;

Future<Map> deleteReception(int id) {
  String sql = '''
    DELETE FROM receptions
    WHERE id = @id;
  ''';

  Map parameters = {'id' : id};

  return connection.execute(sql, parameters).then((rowsAffected) {
    return {'rowsAffected': rowsAffected};
  });
}
