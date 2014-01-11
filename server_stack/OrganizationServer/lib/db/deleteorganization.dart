part of organizationserver.database;

Future<Map> deleteOrganization(int id) {
  String sql = '''
    DELETE FROM organizations
    WHERE id = @id;
  ''';

  Map parameters = {'id' : id};

  return database.execute(_pool, sql, parameters).then((rowsAffected) {
    return {'rowsAffected': rowsAffected};
  });
}
