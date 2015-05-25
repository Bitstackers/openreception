part of receptionserver.database;

/// NOTE: Transactions discards rows, and therefore does not leave us any option
/// to extract the latest ID, or rowcount.

abstract class ReceptionCalendar {

  static final Logger log = new Logger ('$libraryName.ReceptionCalendar');

  static Future<Model.CalendarEntry> createEntry
    (Model.CalendarEntry entry, Model.User user) {
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

INSERT INTO reception_calendar 
  (reception_id,
   event_id)
SELECT 
  @receptionID,
  event_id
FROM entry_change
RETURNING event_id
''';

    Map parameters =
      {'receptionID'      : entry.receptionID,
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



  static Future<int> updateEntry(Model.CalendarEntry entry,
                                 Model.User user) {
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
   * [eventID].
   *
   * Reception Calendar entry associations will be deleted by CASCADE rule in
   * the database.
   */
  static Future removeEntry(int eventID) {
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
   * [receptionID] and [entryID].
   * Returns null if no entry is found.
   */
  static Future<Model.CalendarEntry> get(int receptionID,
                                         int entryID) {
    String sql = '''
SELECT 
  entry.id, 
  entry.start, 
  entry.stop, 
  entry.message, 
  owner.reception_id
FROM 
  reception_calendar owner
JOIN calendar_events entry 
  ON entry.id = owner.event_id
WHERE 
  owner.reception_id = @receptionID 
AND 
  entry.id     = @entryID
LIMIT 1;
''';

    Map parameters =
      {'receptionID' : receptionID,
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
   * reception specified in the parameters.
   */
  static Future<Iterable<Model.CalendarEntry>> list (int receptionID) {

    String sql = '''
    SELECT
      cal.id, 
      cal.start,  
      cal.stop,
      cal.message,
      con.reception_id
    FROM 
      calendar_events cal 
    JOIN 
      reception_calendar con 
    ON 
      cal.id = con.event_id
    WHERE 
      con.reception_id = @receptionID
''';

    Map parameters = {'receptionID' : receptionID};

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
      updated_at 
    FROM 
      calendar_entry_changes 
    WHERE
      entry_id = @entryID 
    ORDER BY 
      last_check 
    DESC;''';

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
      updated_at 
    FROM 
      calendar_entry_changes 
    WHERE
      entry_id = @entryID 
    ORDER BY 
      last_check 
    DESC
    LIMIT 1;''';

    Map parameters = {'entryID' : entryID};
    return connection.query(sql, parameters).then((Iterable rows) =>
      rows.length > 0
        ? _rowToCalendarEventChange (rows.first)
        : throw new Storage.NotFound('entryID:$entryID'));
  }

  static Map _rowToCalendarEventChange(var row) => {
    'uid'     : row.user_id,
    'updated' : Util.dateTimeToUnixTimestamp(row.updated_at)
  };

  static _rowToCalendarEntry (var row) =>
    new Model.CalendarEntry.forReception(row.reception_id)
        ..ID = row.id
        ..beginsAt = row.start
        ..until = row.stop
        ..content = row.message;
}