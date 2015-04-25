part of receptionserver.database;

/// NOTE: Transactions discards rows, and therefore does not leave us any option
/// to extract the latest ID, or rowcount.

abstract class ReceptionCalendar {

  static Future<bool> exists({int receptionID, int eventID}) {
    String sql = '''
SELECT 
  id 
FROM 
  reception_calendar 
JOIN calendar_events event 
  ON event.id = reception_calendar.event_id
WHERE 
  reception_id = @receptionID 
AND 
  event.id     = @eventID
LIMIT 1;
''';

    Map parameters =
      {'receptionID' : receptionID,
       'eventID'     : eventID};

  return connection.query(sql, parameters).then((rows) {
    if (rows.length > 0) {
      return true;
    } else {
      return false;
    }
  });

  }

  //TODO: Return ID
  static Future createEvent({int receptionID, Map event}) {
    String sql = '''
START TRANSACTION;

   INSERT INTO calendar_events 
     ("id", "start", "stop", "message") 
   VALUES 
     (DEFAULT, @start, @end, @content);

   INSERT INTO reception_calendar 
     ("reception_id", "event_id")
   VALUES
     (@receptionID, lastval());
COMMIT;''';

    Map parameters =
      {'receptionID'      : receptionID,
        'start'            : Util.unixTimestampToDateTime(event['start']),
        'end'              : Util.unixTimestampToDateTime(event['stop']),
       'content'           : event['content']};

  return connection.execute(sql, parameters);

  }


  static Future<int> updateEvent({int receptionID, int eventID, Map event}) {
    String sql = '''
   UPDATE calendar_events ce
      SET
          "start"   = @start, 
          "stop"    = @end, 
          "message" = @content
      FROM reception_calendar rc
      WHERE ce.id = @eventID 
        AND rc.reception_id = @receptionID;''';

    Map parameters =
      {'receptionID'      : receptionID,
       'eventID'          : eventID,
       'start'            : Util.unixTimestampToDateTime(event['start']),
       'end'              : Util.unixTimestampToDateTime(event['stop']),
       'content'          : event['content']};

  return connection.execute(sql, parameters).then((int rowsAffected) => rowsAffected);

  }

  static Future removeEvent({int receptionID, int eventID}) {
    String sql = '''
START TRANSACTION;
  DELETE FROM 
     reception_calendar 
  WHERE 
    reception_id = @receptionID 
  AND 
    event_id     = @eventID;
  
  DELETE FROM calendar_events WHERE id = @eventID;

COMMIT; ''';

    Map parameters =
      {'receptionID' : receptionID,
       'eventID'     : eventID};

    return connection.execute(sql, parameters);

  }

  static Future<Model.CalendarEntry> getEvent({int receptionID, int eventID}) {
    String sql = '''
SELECT 
  start, stop, message 
FROM 
  reception_calendar 
JOIN calendar_events event 
  ON event.id = reception_calendar.event_id
WHERE 
  reception_id = @receptionID 
AND 
  event.id     = @eventID
LIMIT 1;
''';

    Map parameters =
      {'receptionID' : receptionID,
       'eventID'     : eventID};

  return connection.query(sql, parameters).then((rows) {
    if (rows.length > 0) {

      var row = rows.first;

      return new Model.CalendarEntry.fromMap(
         { 'id'      : eventID,
           'content' : row.message,
           'start'   : Util.dateTimeToUnixTimestamp(row.start),
           'stop'    : Util.dateTimeToUnixTimestamp(row.stop),
           'reception_id' : receptionID});
    } else {
      return null;
    }
  });
  }

  static Future<List<Model.CalendarEntry>> list(int receptionID) {
    String sql = '''
    SELECT cal.id, cal.start, cal.stop, cal.message
    FROM calendar_events cal JOIN reception_calendar org ON cal.id = org.event_id
    WHERE org.reception_id = @receptionid''';

    Map parameters = {'receptionid' : receptionID};
    return connection.query(sql, parameters).then((rows) {
      List<Model.CalendarEntry> entries = [];
      for(var row in rows) {
        Map event =
          {'id'      : row.id,
           'start'   : Util.dateTimeToUnixTimestamp(row.start),
           'stop'    : Util.dateTimeToUnixTimestamp(row.stop),
           'content' : row.message,
           'reception_id' : receptionID};
        entries.add(new Model.CalendarEntry.fromMap(event));
      }

      return entries;
    });
  }
}