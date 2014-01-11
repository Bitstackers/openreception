part of contactserver.database;

Future<Map> getOrganizationContactCalendarList(int organizationId, int contactId) {
  String sql = '''
    SELECT cal.id, cal.start, cal.stop, cal.message
    FROM calendar_events cal join contact_calendar con on cal.id = con.event_id
    WHERE con.organization_id = @orgid AND con.contact_id = @contactid''';
  
  Map parameters = {'orgid' : organizationId,
                    'contactid': contactId};

  return database.query(_pool, sql, parameters).then((rows) {
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

    return data;
  });
}
