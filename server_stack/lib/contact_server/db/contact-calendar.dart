part of contactserver.database;

abstract class ContactCalendar {

  static final Logger log = new Logger ('$libraryName.ContactCalendar');

  /**
   * Retrieve a CalendarEvent from the database store. Echoes back the inserted
   * CalendarEntry with the database event ID set.
   *
   * TODO: Implement the distribution list.
   */
  static Future<Model.CalendarEntry> createEntry(Model.CalendarEntry entry) {
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
            log.severe('Query did not return any rows! SQL Statement: $sql');
            log.severe('parameters: $parameters');
            return new Future.error(new StateError('Failed to insert event'));
          }

          entry.ID  = rows.first.event_id;

          return entry;
        }).catchError((error, stackTrace) {
          log.severe('Query Failed! SQL Statement: $sql');
          log.severe('parameters: $parameters');
          log.severe(error, stackTrace);
          return new Future.error(error, stackTrace);
        });
    }

  /**
   * Updates a single [Model.CalendarEntry] from the database based on
   * [receptionID], [contactID] and [eventID] members of [entry].
   */
  static Future<int> updateEntry(Model.CalendarEntry entry,
                                 {Map distributionList : null}) {
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

  return connection.execute(sql, parameters)
    .then((int rowsAffected) {
      if (rowsAffected == 0) {
        throw new Storage.NotFound('No event with id ${entry.ID}');
      }

    })
    .catchError((error, stackTrace) {
      log.severe('Query failed! SQL Statement: $sql');
      log.severe('parameters: $parameters');
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    });

  }

  /**
   * Removes a single [Model.CalendarEntry] from the database based on
   * [receptionID], [contactID] and [eventID].
   *
   * TODO: Build a WITH expression that handles the removal atomically without
   *   using explicit transactions.
   */
  static Future removeEntry(int contactID, int receptionID, int eventID) {
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

  /**
   * Retrieve a single [Model.CalendarEntry] from the database based on
   * [receptionID], [contactID] and [eventID].
   */
  static Future<Model.CalendarEntry> getEntry(int contactID,
                                              int receptionID,
                                              int eventID) {
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
    })
    .catchError((error, stackTrace) {
      log.severe('Query failed! SQL Statement: $sql');
      log.severe('parameters: $parameters');
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Returns an [Iterable] of [Model.CalendarEntry] objects associated with
   * contact specified in the parameters.
   */
  static Future<Iterable<Model.CalendarEntry>> list
    (int receptionID, int contactID) {

    String sql = '''
    SELECT
      cal.id, 
      cal.start,  
      cal.stop,
      cal.message
    FROM 
      calendar_events cal 
    JOIN 
      contact_calendar con 
    ON 
      cal.id = con.event_id
    WHERE 
      con.reception_id = @receptionID 
    AND con.contact_id = @contactID
''';

    Map parameters = {'receptionID' : receptionID,
                      'contactID'   : contactID};

    return connection.query(sql, parameters)
      .then((rows) =>
        (rows as List).map((row) =>
          new Model.CalendarEntry.forContact(contactID, receptionID)
            ..ID = row.id
            ..beginsAt = row.start
            ..until = row.stop
            ..content = row.message))

    .catchError((error, stackTrace) {
      log.severe('Query failed! SQL Statement: $sql');
      log.severe('parameters: $parameters');
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    });
  }
}