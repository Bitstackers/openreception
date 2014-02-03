part of contactserver.database;

Future<Map> getReceptionContactCalendarList(int receptionId, int contactId) {
  String sql = '''
    SELECT cal.id, cal.start, cal.stop, cal.message
    FROM calendar_events cal join contact_calendar con on cal.id = con.event_id
    WHERE con.reception_id = @receptionid AND con.contact_id = @contactid''';
  
  Map parameters = {'receptionid' : receptionId,
                    'contactid'   : contactId};

  return database.query(_pool, sql, parameters).then((rows) {
    List events = new List();
    for(var row in rows) {
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
