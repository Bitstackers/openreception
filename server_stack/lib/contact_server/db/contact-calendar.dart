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
        .then((Iterable rows) =>
          rows.isEmpty
            ? new Future.error
                (new StateError('Query did not return any rows!'))
            : (entry..ID = rows.first.event_id))

        .catchError((error, stackTrace) {
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
    .then((int rowsAffected) =>
      rowsAffected > 0
        ? null
        : new Future.error
            (new Storage.NotFound('No event with id ${entry.ID}')))

    .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe('Query failed! SQL Statement: $sql');
        log.severe('parameters: $parameters');
        log.severe(error, stackTrace);
      }
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Removes a single [Model.CalendarEntry] from the database based on
   * [receptionID], [contactID] and [eventID].
   *
   * Calendar entry object will be deleted by CASCADE rule in database.
   */
  static Future removeEntry(int contactID, int receptionID, int eventID) {
    String sql = '''
  DELETE FROM 
     contact_calendar 
  WHERE 
    reception_id = @receptionID 
  AND 
    contact_id   = @contactID
  AND 
    event_id     = @eventID
''';

    Map parameters =
      {'receptionID' : receptionID,
       'contactID'   : contactID,
       'eventID'     : eventID};

    return connection.execute(sql, parameters)
      .then((int rowsAffected) =>
        rowsAffected > 0
          ? null
          : new Future.error(new Storage.NotFound('en')))

      .catchError((error, stackTrace) {
        if (error is! Storage.NotFound) {
          log.severe('Query failed! SQL Statement: $sql');
          log.severe('parameters: $parameters');
          log.severe(error, stackTrace);
        }

        return new Future.error(error, stackTrace);
      });

  }

  /**
   * Retrieve a single [Model.CalendarEntry] from the database based on
   * [receptionID], [contactID] and [entryID].
   * Returns null if no entry is found.
   */
  static Future<Model.CalendarEntry> get(int contactID,
                                         int receptionID,
                                         int entryID) {
    String sql = '''
SELECT 
  entry.id, 
  entry.start, 
  entry.stop, 
  entry.message, 
  owner.reception_id,
  owner.contact_id
FROM 
  contact_calendar owner
JOIN calendar_events entry 
  ON entry.id = owner.event_id
WHERE 
  owner.reception_id = @receptionID 
AND 
  owner.contact_id   = @contactID
AND 
  entry.id     = @entryID
LIMIT 1;
''';

    Map parameters =
      {'receptionID' : receptionID,
       'contactID'   : contactID,
       'entryID'     : entryID};

  return connection.query(sql, parameters)
    .then((rows) =>
      rows.length > 0
        ? _rowToCalendarEntry(rows.first)
        : new Future.error(new Storage.NotFound('eid:$entryID')))

    .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe('Query failed! SQL Statement: $sql');
        log.severe('parameters: $parameters');
        log.severe(error, stackTrace);
      }
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
      cal.message,
      con.reception_id,
      con.contact_id
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
        (rows as List).map(_rowToCalendarEntry))

    .catchError((error, stackTrace) {
      log.severe('Query failed! SQL Statement: $sql');
      log.severe('parameters: $parameters');
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    });
  }

  static _rowToCalendarEntry (var row) =>
    new Model.CalendarEntry.forContact(row.contact_id, row.reception_id)
        ..ID = row.id
        ..beginsAt = row.start
        ..until = row.stop
        ..content = row.message;
}