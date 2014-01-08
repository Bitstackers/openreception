part of db;

Future<Map> getOrganization(int id) {
  return _pool.connect().then((Connection conn) {
    String sql = '''
      SELECT id, full_name, uri, attributes, enabled
      FROM organizations
      WHERE id = @id 
    ''';

    Map parameters = {'id' : id};

    return conn.query(sql, parameters).toList().then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'organization_id' : row.id,
           'full_name'       : row.full_name,
           'uri'             : row.uri,
           'enabled'         : row.enabled};
        
        if (row.attributes != null) {
          Map attributes = JSON.decode(row.attributes);
          if(attributes != null) {
            attributes.forEach((key, value) => data.putIfAbsent(key, () => value));
          }
        }
      }

      return data;
    }).whenComplete(() => conn.close());
  });
}
