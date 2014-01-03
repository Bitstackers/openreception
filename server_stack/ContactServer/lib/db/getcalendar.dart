part of db;

Future<Map> getOrganizationContactCalendarList(int organizationId, int contactId) {
  Completer completer = new Completer();

  _pool.connect().then((Connection conn) {
    String sql = '''
SELECT cal.id, cal.start, cal.stop, cal.message
FROM calendar_events cal join contact_calendar con on cal.id = con.event_id
WHERE con.organization_id = @orgid AND con.contact_id = @contactid''';
    
    Map parameters = {'orgid' : organizationId,
                      'contactid': contactId};

    conn.query(sql, parameters).toList().then((rows) {
      List contacts = new List();
      for(var row in rows) {
        Map contact =
          {'id'      : row.id,
           'start'   : datetimeToJson(row.start),
           'stop'    : datetimeToJson(row.stop),
           'message' : row.message};
        contacts.add(contact);
      }

      Map data = {'CalendarEvents': contacts};

      completer.complete(data);
    }).catchError((err) { 
      log('conn.query Failed. $err');
      completer.completeError(err);
    })
      .whenComplete(() => conn.close());
  }).catchError((err) { 
    log('_pool.connect Failed. $err');
    completer.completeError(err);
  });

  return completer.future;
}
