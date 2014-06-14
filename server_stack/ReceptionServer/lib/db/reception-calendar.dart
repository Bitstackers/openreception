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

  return database.query(_pool, sql, parameters).then((rows) {
    if (rows.length > 0) {
      return true;
    } else {
      return false;
    }
  });
  
  }

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
       'start'            : new DateTime.fromMillisecondsSinceEpoch(event['start']*1000),
       'end'              : new DateTime.fromMillisecondsSinceEpoch(event['stop']*1000),
       'content'           : event['content']};
    
  return database.execute(_pool, sql, parameters);
  
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
       'start'            : new DateTime.fromMillisecondsSinceEpoch(event['start']*1000),
       'end'              : new DateTime.fromMillisecondsSinceEpoch(event['stop']*1000),
       'content'          : event['content']};

  return database.execute(_pool, sql, parameters).then((int rowsAffected) => rowsAffected);
  
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

    print (sql);
    return database.execute(_pool, sql, parameters);
  
  }

  static Future<Map> getEvent({int receptionID, int eventID}) {
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

  return database.query(_pool, sql, parameters).then((rows) {
    if (rows.length > 0) {
    
      var row = rows.first;
    
      return {'content' : row.message,
              'start'   : dateTimeToUnixTimestamp(row.start),
              'stop'    : dateTimeToUnixTimestamp(row.stop)};
    } else {
      return null;
    }
  });
  
  }
}