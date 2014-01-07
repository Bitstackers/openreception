part of db;

Future<Map> getOrganizationList() {
  return _pool.connect().then((Connection conn) {
    String sql = '''
      SELECT id, full_name, uri, enabled, attributes
      FROM organizations
    ''';
    
    return conn.query(sql).toList().then((rows) {
      List organizations = new List();
      for(var row in rows) {
        Map organization =
          {'organization_id' : row.id,
           'full_name'       : row.full_name,
           'uri'             : row.uri,
           'enabled'         : row.enabled};

        JSON.decode(row.attributes).forEach((key, value) => organization.putIfAbsent(key, () => value));
        organizations.add(organization);
      }
      
      return {'organization_list':organizations};
    }).whenComplete(() => conn.close());
  });
}
