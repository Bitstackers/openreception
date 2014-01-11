part of organizationserver.database;

Future<Map> getOrganizationList() {
  String sql = '''
    SELECT id, full_name, uri, enabled, attributes
    FROM organizations
  ''';  
  return database.query(_pool, sql).then((rows) {
    List organizations = new List();
    for(var row in rows) {
      Map organization =
        {'organization_id' : row.id,
         'full_name'       : row.full_name,
         'uri'             : row.uri,
         'enabled'         : row.enabled};

      if (row.attributes != null) {
        Map attributes = JSON.decode(row.attributes);
        if(attributes != null) {
          attributes.forEach((key, value) => organization.putIfAbsent(key, () => value));
        }
      }
      organizations.add(organization);
    }
    
    return {'organization_list':organizations};
  });
}
