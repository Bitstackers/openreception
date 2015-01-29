part of contactserver.database;

/// NOTE: Transactions discards rows, and therefore does not leave us any option
/// to extract the latest ID, or rowcount.

abstract class ContactCalendar {

  static Future<bool> exists({int contactID, int receptionID, int eventID}) {
    String sql = '''
SELECT 
  id 
FROM 
  contact_calendar 
JOIN calendar_events event 
  ON event.id = contact_calendar.event_id
WHERE 
  reception_id = @receptionID 
AND 
  contact_id   = @contactID
AND 
  event.id     = @eventID
LIMIT 1;
''';

    Map parameters =
      {'receptionID' : receptionID,
       'contactID'   : contactID,
       'eventID'     : eventID};

  return connection.query(sql, parameters).then((rows) {
    if (rows.length > 0) {
      return true;
    } else {
      return false;
    }
  });

  }

  static Future createEvent({int contactID, int receptionID, Map event, Map distributionList : null}) {
    String sql = '''
START TRANSACTION;

   INSERT INTO calendar_events 
     ("id", "start", "stop", "message") 
   VALUES 
     (DEFAULT, @start, @end, @content);

   INSERT INTO contact_calendar 
     ("reception_id", "contact_id", 
"distribution_list", "event_id")
   VALUES
     (@receptionID, @contactID, @distributionList, lastval());
COMMIT;''';

    Map parameters =
      {'receptionID'      : receptionID,
       'contactID'        : contactID,
       'distributionList' : distributionList,
       'start'            : Util.unixTimestampToDateTime(event['start']),
       'end'              : Util.unixTimestampToDateTime(event['stop']),
       'content'          : event['content']};

    print (sql);
  return connection.execute(sql, parameters);

  }


  static Future<int> updateEvent({int contactID, int receptionID, int eventID, Map event, Map distributionList : null}) {
    String sql = '''
   UPDATE calendar_events ce
      SET
          "start"   = @start, 
          "stop"    = @end, 
          "message" = @content
      FROM contact_calendar cc
      WHERE ce.id = @eventID 
        AND cc.contact_id   = @contactID
        AND cc.reception_id = @receptionID;''';

    Map parameters =
      {'receptionID'      : receptionID,
       'contactID'        : contactID,
       'eventID'          : eventID,
       'distributionList' : distributionList,
       'start'            : Util.unixTimestampToDateTime(event['start']),
       'end'              : Util.unixTimestampToDateTime(event['stop']),
       'content'          : event['content']};

  return connection.execute(sql, parameters).then((int rowsAffected) => rowsAffected);

  }

  static Future removeEvent({int contactID, int receptionID, int eventID}) {
    String sql = '''
START TRANSACTION;
  DELETE FROM 
     contact_calendar 
  WHERE 
    reception_id = @receptionID 
  AND 
    contact_id   = @contactID
  AND 
    event_id     = @eventID;
  
  DELETE FROM calendar_events WHERE id = @eventID;

COMMIT; ''';

    Map parameters =
      {'receptionID' : receptionID,
       'contactID'   : contactID,
       'eventID'     : eventID};

    return connection.execute(sql, parameters);

  }

  static Future<Map> getEvent({int contactID, int receptionID, int eventID}) {
    String sql = '''
SELECT 
  start, stop, message 
FROM 
  contact_calendar 
JOIN calendar_events event 
  ON event.id = contact_calendar.event_id
WHERE 
  reception_id = @receptionID 
AND 
  contact_id   = @contactID
AND 
  event.id     = @eventID
LIMIT 1;
''';

    Map parameters =
      {'receptionID' : receptionID,
       'contactID'   : contactID,
       'eventID'     : eventID};

  return connection.query(sql, parameters).then((rows) {
    if (rows.length > 0) {

      var row = rows.first;

      return {'content' : row.message,
              'start'   : Util.dateTimeToUnixTimestamp(row.start),
              'stop'    : Util.dateTimeToUnixTimestamp(row.stop)};
    } else {
      return null;
    }
  });

  }
}