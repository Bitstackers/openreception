part of organizationserver.database;

Future<Map> getOrganizationCalendarList(int organizationId) {
  String sql = '''
    SELECT cal.id, cal.start, cal.stop, cal.message
    FROM calendar_events cal JOIN organization_calendar org ON cal.id = org.event_id
    WHERE org.organization_id = @orgid''';
  
  Map parameters = {'orgid' : organizationId};
  return database.query(_pool, sql, parameters).then((rows) {
    List events = new List();
    for(var row in rows) {
      Map event =
        {'id'      : row.id,
         'start'   : datetimeToJson(row.start),
         'stop'    : datetimeToJson(row.stop),
         'message' : row.message};
      events.add(event);
    }
    
    Map data = {'CalendarEvents': events};

    return data;
  });
}
