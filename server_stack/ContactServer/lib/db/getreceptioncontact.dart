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
             con.enabled as conenabled,
             (SELECT array_to_json(array_agg(row_to_json(row)))
              FROM (SELECT 
              pn.id, pn.value, pn.kind
              FROM contact_phone_numbers cpn
                JOIN phone_numbers pn on cpn.phone_number_id = pn.id
              WHERE cpn.reception_id = @receptionid AND cpn.contact_id = @contactid
              ) row) as phone
      FROM   contacts con 
        JOIN reception_contacts rcpcon on con.id = rcpcon.contact_id
      WHERE  rcpcon.reception_id = @receptionid 
         AND rcpcon.contact_id = @contactid;''';

    Map parameters = {'receptionid' : receptionId,
                      'contactid': contactId};

    return database.query(_pool, sql, parameters).then((rows) {
      Map data = {};
      if(rows != null && rows.length == 1) {
        var row = rows.first;
        data =
          {'reception_id'   : row.reception_id,
           'contact_id'     : row.contact_id,
           'wants_messages' : row.wants_messages,
           'enabled'        : row.rcpenabled && row.conenabled,
           'full_name'      : row.full_name,
           'contact_type'   : row.contact_type,
           'phones'         : row.phone != null ? JSON.decode(row.phone) : []};
        
        if(row.attributes != null) {
          JSON.decode(row.attributes).forEach((key, value) => data.putIfAbsent(key, () => value));
        }
      }
      
      return data;
    });
}
