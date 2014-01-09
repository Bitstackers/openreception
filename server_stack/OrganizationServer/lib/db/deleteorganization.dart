part of organizationserver.db;

Future<Map> deleteOrganization(int id) {
 return _pool.connect().then((Connection conn) {
    String sql = '''
      DELETE FROM organizations
      WHERE id = @id;
    ''';

    Map parameters = {'id' : id};

    return conn.execute(sql, parameters).then((rowsAffected) {
      return {'rowsAffected': rowsAffected};
    }).whenComplete(() => conn.close());
  });
}
