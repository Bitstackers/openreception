part of adaheads.server.database;

Future<int> _createEndpoint(Pool pool, int receptionid, int contactid, String address, String type, bool confidential, bool enabled, int priority) {
  String sql = '''
    INSERT INTO messaging_end_points (contact_id, reception_id, address, address_type, confidential, enabled, priority)
    VALUES (@receptionid, @contactid, @address, @addresstype, @confidential, @enabled, @priority);
  ''';

  Map parameters =
    {'receptionid' : receptionid,
     'contactid'   : contactid,
     'address'     : address,
     'addresstype' : type,
     'confidential': confidential,
     'enabled'     : enabled,
     'priority'    : priority};

  return execute(pool, sql, parameters);
}

Future<int> _deleteEndpoint(Pool pool, int receptionid, int contactid, String address, String type) {
  String sql = '''
      DELETE FROM messaging_end_points
      WHERE reception_id=@receptionid AND contact_id=@contactid AND address=@address AND address_type=@addresstype;
    ''';

  Map parameters =
      {'receptionid' : receptionid,
       'contactid'   : contactid,
       'address'     : address,
       'addresstype' : type};
  return execute(pool, sql, parameters);
}

Future<model.Endpoint> _getEndpoint(Pool pool, int receptionid, int contactid, String address, String type) {
  String sql = '''
    SELECT contact_id, reception_id, address, address_type, confidential, enabled, priority
    FROM messaging_end_points
    WHERE reception_id=@receptionid AND contact_id=@contactid AND address=@address AND address_type=@addresstype;
  ''';

  Map parameters =
      {'receptionid' : receptionid,
       'contactid'   : contactid,
       'address'     : address,
       'addresstype' : type};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new model.Endpoint(row.contact_id, row.reception_id, row.address, row.address_type, row.confidential, row.enabled, row.priority);
    }
  });
}

Future<List<model.Endpoint>> _getEndpointList(Pool pool, int receptionid, int contactid) {
  String sql = '''
    SELECT contact_id, reception_id, address, address_type, confidential, enabled, priority
    FROM messaging_end_points
    WHERE reception_id=@receptionid AND contact_id=@contactid;
  ''';

  Map parameters =
      {'receptionid' : receptionid,
       'contactid'   : contactid};

  return query(pool, sql, parameters).then((rows) {
    List<model.Endpoint> endpoints = new List<model.Endpoint>();
    for(var row in rows) {
      endpoints.add(new model.Endpoint(row.contact_id, row.reception_id, row.address, row.address_type, row.confidential, row.enabled, row.priority));
    }
    return endpoints;
  });
}

Future<int> _updateEndpoint(Pool pool, int fromReceptionid, int fromContactid, String fromAddress, String fromType, int receptionid, int contactid, String address, String type, bool confidential, bool enabled, int priority) {
  String sql = '''
    UPDATE messaging_end_points
    SET reception_id=@receptionid,
        contact_id=@contactid, 
        address=@address, 
        address_type=@addresstype, 
        confidential=@confidential, 
        enabled=@enabled, 
        priority=@priority
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
     'priority'    : priority};

  return execute(pool, sql, parameters);
}
