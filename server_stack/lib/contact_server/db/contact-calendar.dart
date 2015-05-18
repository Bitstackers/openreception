part of contactserver.database;

/// NOTE: Transactions discards rows, and therefore does not leave us any option
/// to extract the latest ID, or rowcount.

abstract class ContactCalendar {

  static final Logger log = new Logger ('$libraryName.ContactCalendar');

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

  static Future<Model.CalendarEntry> createEvent(Model.CalendarEntry entry) {
    String sql = '''
WITH new_event AS(
INSERT INTO calendar_events (start, stop, message)
    VALUES (@start, @end, @content)
    RETURNING id as event_id
)
INSERT INTO contact_calendar 
  (reception_id, 
   contact_id, 
   event_id)
SELECT 
  @receptionID,
  @contactID, 
  event_id
FROM new_event
RETURNING event_id
''';

    Map parameters =
      {'receptionID'      : entry.receptionID,
       'contactID'        : entry.contactID,
       'start'            : entry.start,
       'end'              : entry.stop,
       'content'          : entry.content};

    return connection.query(sql, parameters)
        .then((Iterable rows) {
          if(rows.isEmpty) {
            //TODO: Log parameters SQL.
            return new Future.error(new StateError('Failed to insert event'));
          }

          entry.ID  = rows.first.event_id;

          return entry;
        }).catchError((error, stackTrace) {
          log.severe(error, stackTrace);
          return new Future.error(error, stackTrace);
        });
    }


  static Future<int> updateEvent(Model.CalendarEntry entry, {Map distributionList : null}) {
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
      {'receptionID'      : entry.receptionID,
       'contactID'        : entry.contactID,
       'eventID'          : entry.ID,
       'distributionList' : distributionList,
       'start'            : entry.start,
       'end'              : entry.stop,
       'content'          : entry.content};

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

  static Future<Model.CalendarEntry> getEvent({int contactID, int receptionID, int eventID}) {
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

      Map map =
                {'id'      : eventID,
                 'start'   : Util.dateTimeToUnixTimestamp(row.start),
                 'stop'    : Util.dateTimeToUnixTimestamp(row.stop),
                 'contact_id' : contactID,
                 'reception_id' : receptionID,
                 'content' : row.message};

      return new Model.CalendarEntry.fromMap(map);
    } else {
      return null;
    }
    });
  }

  static Future<Iterable<Model.CalendarEntry>> list(int receptionId, int contactId) {
    String sql = '''
    SELECT cal.id, cal.start, cal.stop, cal.message
    FROM calendar_events cal join contact_calendar con on cal.id = con.event_id
    WHERE con.reception_id = @receptionid AND con.contact_id = @contactid''';

    Map parameters = {'receptionid' : receptionId,
                      'contactid'   : contactId};

    return connection.query(sql, parameters).then((rows) {
      return (rows as List).map((row) {
        Map map =
          {'id'      : row.id,
           'start'   : Util.dateTimeToUnixTimestamp(row.start),
           'stop'    : Util.dateTimeToUnixTimestamp(row.stop),
           'contact_id' : contactId,
           'reception_id' : receptionId,
           'content' : row.message};
        return new Model.CalendarEntry.fromMap(map);
      });
    });
  }
}