part of receptionserver.database;

Future<Map> getReceptionCalendarList(int receptionId) {
  String sql = '''
    SELECT cal.id, cal.start, cal.stop, cal.message
    FROM calendar_events cal JOIN reception_calendar org ON cal.id = org.event_id
    WHERE org.reception_id = @receptionid''';
  
  Map parameters = {'receptionid' : receptionId};
  return database.query(_pool, sql, parameters).then((rows) {
    List events = new List();
    for(var row in rows) {
      DateTime now = new DateTime.now();
      Map event =
        {'id'      : row.id,
         'start'   : datetimeToJson(row.start),
         'stop'    : datetimeToJson(row.stop),
         'content' : row.message};
      events.add(event);
    }
    
    Map data = {'CalendarEvents': events};

    return data;
  });
}
