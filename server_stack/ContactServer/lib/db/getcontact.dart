part of db;

Future<Map> getContact(int orgId, int contactId) {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
SELECT orgcon.organization_id, orgcon.contact_id, orgcon.wants_messages, orgcon.attributes, orgcon.enabled, con.full_name, con.contact_type, con.enabled
FROM contacts con join organization_contacts orgcon on con.id = orgcon.contact_id
WHERE orgcon.organization_id = @orgid AND orgcon.contact_id = @contactid''';

    Map parameters = {'orgid' : orgId,
                      'contactid': contactId};

    conn.query(sql, parameters).toList().then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'organization_id'        : row.organization_id,
           'contact_id' : row.contact_id,
           'wants_messages'       : row.wants_messages,
           'attributes': JSON.decode(row.attributes),
           'enabled'   : row.enabled,
           'full_name':row.full_name,
           'contact_type': row.contact_type};
      }

      completer.complete(data);
    }).catchError((err) => completer.completeError(err))
      .whenComplete(() => conn.close());
  }).catchError((err) => completer.completeError(err));

  return completer.future;
}
