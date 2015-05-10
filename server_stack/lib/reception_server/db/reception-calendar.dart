part of receptionserver.database;

/// NOTE: Transactions discards rows, and therefore does not leave us any option
/// to extract the latest ID, or rowcount.

abstract class ReceptionCalendar {
  
  static final Logger log = new Logger ('$libraryName.ReceptionCalendar');
  
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

  static Future<Model.CalendarEntry> createEvent(int receptionID, Model.CalendarEntry event) {
    String sql = '''
WITH new_event AS(
INSERT INTO calendar_events (start, stop, message)
    VALUES (@start, @end, @content)
    RETURNING id as event_id
)
INSERT INTO reception_calendar
SELECT @receptionID, event_id
FROM new_event
RETURNING event_id
''';

    Map parameters =
      {'receptionID'      : receptionID,
        'start'            : event.startTime,
        'end'              : event.stopTime,
       'content'           : event.content};

  return connection.query(sql, parameters)
    .then((Iterable rows) {
      if(rows.isEmpty) {
        //TODO: Log parameters SQL.
        return new Future.error(new StateError('Failed to insert event'));
      }
      
      event.ID  = rows.first.event_id;

      return event;
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    });
      
  }


  static Future<int> updateEvent(int receptionID, Model.CalendarEntry event) {
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
       'eventID'          : event.ID,
       'start'            : event.startTime,
       'end'              : event.stopTime,
       'content'          : event.content};

  return connection.execute(sql, parameters);

  }

  static Future removeEvent(int receptionID, int eventID) {
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

  static Future<Iterable<Model.CalendarEntry>> list(int receptionID) {
    String sql = '''
    SELECT cal.id, cal.start, cal.stop, cal.message
    FROM calendar_events cal JOIN reception_calendar org ON cal.id = org.event_id
    WHERE org.reception_id = @receptionid''';

    Model.CalendarEntry rowToCalendarEvent(var row) =>
      new Model.CalendarEntry.forReception(receptionID)
        ..ID = row.id
        ..beginsAt = row.start
        ..until = row.stop
        ..content = row.message;

    Map parameters = {'receptionid' : receptionID};
    return connection.query(sql, parameters).then((Iterable rows) =>
      rows.map(rowToCalendarEvent));
  }
}