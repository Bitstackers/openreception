part of adaheads.server.database;

Future<int> _createEndpoint(ORDatabase.Connection connection, int receptionid, int contactid, String address, String type, bool confidential, bool enabled, int priority, String description) {
  String sql = '''
    INSERT INTO messaging_end_points (contact_id, reception_id, address, address_type, confidential, enabled, priority, description)
    VALUES (@contactid, @receptionid,  @address, @addresstype, @confidential, @enabled, @priority, @description);
  ''';

  Map parameters =
    {'receptionid' : receptionid,
     'contactid'   : contactid,
     'address'     : address,
     'addresstype' : type,
     'confidential': confidential,
     'enabled'     : enabled,
     'priority'    : priority,
     'description' : description};

  return connection.execute(sql, parameters);
}

Future<int> _deleteEndpoint(ORDatabase.Connection connection, int receptionid, int contactid, String address, String type) {
  String sql = '''
      DELETE FROM messaging_end_points
      WHERE reception_id=@receptionid AND contact_id=@contactid AND address=@address AND address_type=@addresstype;
    ''';

  Map parameters =
      {'receptionid' : receptionid,
       'contactid'   : contactid,
       'address'     : address,
       'addresstype' : type};
  return connection.execute(sql, parameters);
}

Future<model.Endpoint> _getEndpoint(ORDatabase.Connection connection, int receptionid, int contactid, String address, String type) {
  String sql = '''
    SELECT contact_id, reception_id, address, address_type, confidential, enabled, priority, description
    FROM messaging_end_points
    WHERE reception_id=@receptionid AND contact_id=@contactid AND address=@address AND address_type=@addresstype;
  ''';

  Map parameters =
      {'receptionid' : receptionid,
       'contactid'   : contactid,
       'address'     : address,
       'addresstype' : type};

  return connection.query(sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      var row = rows.first;
      return new model.Endpoint(row.contact_id, row.reception_id, row.address, row.address_type, row.confidential, row.enabled, row.priority, row.description);
    }
  });
}

Future<List<model.Endpoint>> _getEndpointList(ORDatabase.Connection connection, int receptionid, int contactid) {
  String sql = '''
    SELECT contact_id, reception_id, address, address_type, confidential, enabled, priority, description
    FROM messaging_end_points
    WHERE reception_id=@receptionid AND contact_id=@contactid;
  ''';

  Map parameters =
      {'receptionid' : receptionid,
       'contactid'   : contactid};

  return connection.query(sql, parameters).then((List rows) {
    List<model.Endpoint> endpoints = new List<model.Endpoint>();
    for(var row in rows) {
      endpoints.add(new model.Endpoint(row.contact_id, row.reception_id, row.address, row.address_type, row.confidential, row.enabled, row.priority, row.description));
    }
    return endpoints;
  });
}

Future<int> _updateEndpoint(ORDatabase.Connection connection, int fromReceptionid, int fromContactid, String fromAddress, String fromType, int receptionid, int contactid, String address, String type, bool confidential, bool enabled, int priority, String description) {
  String sql = '''
    UPDATE messaging_end_points
    SET reception_id=@receptionid,
        contact_id=@contactid, 
        address=@address, 
        address_type=@addresstype, 
        confidential=@confidential, 
        enabled=@enabled, 
        priority=@priority,
        description=@description
    WHERE reception_id=@fromreceptionid AND
          contact_id=@fromcontactid AND
          address=@fromaddress AND
          address_type=@fromaddresstype;
  ''';

  Map parameters =
    {'fromreceptionid' : receptionid,
     'fromcontactid'   : contactid,
     'fromaddress'     : address,
     'fromaddresstype' : type,

     'receptionid' : receptionid,
     'contactid'   : contactid,
     'address'     : address,
     'addresstype' : type,
     'confidential': confidential,
     'enabled'     : enabled,
     'priority'    : priority,
     'description' : description};

  return connection.execute(sql, parameters);
}
