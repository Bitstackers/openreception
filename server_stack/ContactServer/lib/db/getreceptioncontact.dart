part of contactserver.database;

Future<Map> getContact(int receptionId, int contactId) {
    String sql = '''
      SELECT rcpcon.reception_id, 
             rcpcon.contact_id, 
             rcpcon.wants_messages, 
             rcpcon.attributes, 
             rcpcon.enabled as rcpenabled, 
             con.full_name, 
             con.contact_type, 
             con.enabled as conenabled
      FROM   contacts con 
        JOIN reception_contacts rcpcon on con.id = rcpcon.contact_id
      WHERE  rcpcon.reception_id = @receptionid 
         AND rcpcon.contact_id = @contactid''';

    Map parameters = {'receptionid' : receptionId,
                      'contactid': contactId};

    return database.query(_pool, sql, parameters).then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'reception_id'   : row.reception_id,
           'contact_id'     : row.contact_id,
           'wants_messages' : row.wants_messages,
           'enabled'        : row.rcpenabled && row.conenabled,
           'full_name'      : row.full_name,
           'contact_type'   : row.contact_type};
        
        JSON.decode(row.attributes).forEach((key, value) => data.putIfAbsent(key, () => value));
      }
      
      return data;
    });
}
