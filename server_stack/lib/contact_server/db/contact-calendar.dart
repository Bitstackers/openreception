part of contactserver.database;

abstract class ContactCalendar {

  static final Logger log = new Logger ('$libraryName.ContactCalendar');

  /**
   * Retrieve a CalendarEvent from the database store. Echoes back the inserted
   * CalendarEntry with the database event ID set.
   *
   * TODO: Implement the distribution list.
   */
  static Future<Model.CalendarEntry> createEntry(Model.CalendarEntry entry, Model.User user) {
    String sql = '''
WITH new_event AS(
  INSERT INTO calendar_events (start, stop, message)
    VALUES (@start, @end, @content)
    RETURNING id as event_id
),
entry_change AS (
  INSERT INTO calendar_entry_changes (user_id, entry_id)
    SELECT @userID, event_id
    FROM new_event
    RETURNING entry_id as event_id
)

INSERT INTO contact_calendar 
  (reception_id, 
   contact_id,
   event_id)
SELECT 
  @receptionID,
  @contactID,
  event_id
FROM entry_change
RETURNING event_id
''';

    Map parameters =
      {'receptionID'      : entry.receptionID,
       'contactID'        : entry.contactID,
       'start'            : entry.start,
       'end'              : entry.stop,
       'userID'           : user.ID,
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
   *
   * TODO: Take the distribution list into accout.
   */
  static Future<int> updateEntry(Model.CalendarEntry entry,
                                 Model.User user,
                                 {Map distributionList : null}) {
    String sql = '''
WITH updated_event AS (
   UPDATE calendar_events ce
      SET
          start   = @start,
          stop    = @stop,
          message = @content
      WHERE ce.id = @eventID
      RETURNING ce.id AS entry_id
),
changed_entry AS (
  INSERT INTO calendar_entry_changes (user_id, entry_id)
  SELECT @userID, entry_id
  FROM updated_event
  RETURNING entry_id
)

SELECT entry_id FROM changed_entry;
''';

    Map parameters =
      {'eventID'          : entry.ID,
       'distributionList' : distributionList,
       'start'            : entry.start,
       'stop'             : entry.stop,
       'content'          : entry.content,
       'userID'           : user.ID};

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
   * Contact Calendar entry associations will be deleted by CASCADE rule in
   * the database.
   */
  static Future removeEntry(int contactID, int receptionID, int eventID) {
    String sql = '''
  DELETE FROM 
     calendar_events 
  WHERE 
    id     = @eventID
''';

    Map parameters =
      {'eventID'     : eventID};

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

  static Future<Iterable<Map>> changes (int entryID) {
    String sql = '''
    SELECT 
      user_id, 
      updated_at,
      name
    FROM 
      calendar_entry_changes 
    JOIN
      users
    ON 
      users.id = user_id
    WHERE
      entry_id = @entryID
    ORDER BY 
      updated_at 
    DESC''';

    Map parameters = {'entryID' : entryID};
    return connection.query(sql, parameters).then((Iterable rows) =>
      rows.map(_rowToCalendarEventChange));
  }

  /**
   * NOTE: This is potentially inefficient, as it may compute and order every
   *   row associated with eventID. The primary gain from this function, however
   *   would be easy access to the latest change from the client.
   */
  static Future<Map> latestChange (int entryID) {
    String sql = '''
    SELECT 
      user_id, 
      updated_at,
      name
    FROM 
      calendar_entry_changes 
    JOIN
      users
    ON 
      users.id = user_id
    WHERE
      entry_id = @entryID
    ORDER BY 
      updated_at 
    DESC
    LIMIT 1''';

    Map parameters = {'entryID' : entryID};
    return connection.query(sql, parameters).then((Iterable rows) =>
      rows.length > 0
        ? _rowToCalendarEventChange (rows.first)
        : throw new Storage.NotFound('entryID:$entryID'));
  }

  static Map _rowToCalendarEventChange(var row) => {
    'uid'      : row.user_id,
    'updated'  : Util.dateTimeToUnixTimestamp(row.updated_at),
    'username' : row.name
  };

  static _rowToCalendarEntry (var row) =>
    new Model.CalendarEntry.contact(row.contact_id, row.reception_id)
        ..ID = row.id
        ..beginsAt = row.start
        ..until = row.stop
        ..content = row.message;

}