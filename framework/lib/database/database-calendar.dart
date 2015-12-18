/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.database;

class Calendar implements Storage.Calendar {
  static final Logger log = new Logger('$libraryName.Calendar');

  final Connection _connection;

  Calendar(this._connection);


  String _ownerTable(Model.Owner owner) => owner is Model.OwningContact
      ? 'contact_calendar'
      : owner is Model.OwningReception
          ? 'reception_calendar'
          : throw new ArgumentError(
              'Undefined owner type ${owner.runtimeType}');

  String _ownerField(Model.Owner owner) => owner is Model.OwningContact
      ? 'contact_id'
      : owner is Model.OwningReception
          ? 'reception_id'
          : throw new ArgumentError(
              'Undefined owner type ${owner.runtimeType}');

  int _ownerId(Model.Owner owner) => owner is Model.OwningContact
      ? owner.contactId
      : owner is Model.OwningReception
          ? owner.receptionId
          : throw new ArgumentError(
              'Undefined owner type ${owner.runtimeType}');


  /**
   * Retrieve a single [Model.CalendarEntry] from the database based
   * on [entryID].
   */
  Future<Model.CalendarEntry> get(int entryID, {bool deleted: false}) {
    String sql = '''
SELECT 
  entry.id, 
  entry.start, 
  entry.stop, 
  entry.message,
  r.reception_id,
  c.contact_id
FROM 
  calendar_events entry
LEFT JOIN reception_calendar r ON r.event_id = entry.id
LEFT JOIN contact_calendar c ON c.event_id = entry.id
WHERE
  ${deleted ? '' : 'NOT'} deleted
AND 
  entry.id = @entryID;
''';

    Map parameters = {'entryID': entryID};

    return _connection
        .query(sql, parameters)
        .then((rows) => rows.length > 0
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
   * Creates a [CalendarEntry] object in the database.
   */
  Future<Model.CalendarEntry> create(Model.CalendarEntry entry, int userId) {
    final String sql = '''
WITH new_event AS(
  INSERT INTO calendar_events (start, stop, message)
    VALUES (@start, @end, @content)
    RETURNING id as event_id
),
entry_change AS (
  INSERT INTO calendar_entry_changes (user_id, last_entry, entry_id)
    SELECT @userID, '{}', event_id
    FROM new_event
    RETURNING entry_id as event_id
)

INSERT INTO ${_ownerTable(entry.owner)} 
  (${_ownerField(entry.owner)},
   event_id)
SELECT 
  ${_ownerId(entry.owner)},
  event_id
FROM entry_change
RETURNING event_id
''';

    Map parameters = {
      'start': entry.start,
      'end': entry.stop,
      'userID': userId,
      'content': entry.content
    };

    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.isEmpty
            ? new Future.error(new StateError('Query did not return any rows!'))
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
   * [owner] of the [entry].
   *
   * TODO: Take the distribution list into accout.
   */
  Future<Model.CalendarEntry> update(Model.CalendarEntry entry, int userId) async {
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
  INSERT INTO calendar_entry_changes (user_id, last_entry, entry_id)
  SELECT @userID, @lastEntry, entry_id
  FROM updated_event
  RETURNING entry_id
)

SELECT entry_id FROM changed_entry;
''';

    Map parameters = {
      'eventID': entry.ID,
      'start': entry.start,
      'stop': entry.stop,
      'content': entry.content,
      'lastEntry' : (await get(entry.ID)).toJson(),
      'userID': userId
    };

    return _connection
        .execute(sql, parameters)
        .then((int rowsAffected) => rowsAffected > 0
            ? entry
            : new Future.error(
                new Storage.NotFound('No event with id ${entry.ID}')))
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
   * Removes a single [Model.CalendarEntry] from the database based
   * on [eventID].
   *
   * Contact Calendar entry associations will be deleted by CASCADE rule in
   * the database.
   */
  Future remove(entryId, userId) async {
    const String sql = '''
WITH updated_event AS (
   UPDATE calendar_events ce
      SET deleted = true
      WHERE ce.id = @eventID
      RETURNING ce.id AS entry_id
),
changed_entry AS (
  INSERT INTO calendar_entry_changes (user_id, last_entry, entry_id)
  SELECT @userId, @lastEntry, entry_id
  FROM updated_event
  RETURNING entry_id
)

SELECT entry_id FROM changed_entry;
''';

    Model.CalendarEntry lastEntry = await get(entryId);

    Map parameters = {
      'eventID': entryId,
      'lastEntry': lastEntry.toJson(),
      'userId': userId
    };

    return _connection
        .execute(sql, parameters)
        .then((int rowsAffected) => rowsAffected > 0
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
   * Returns an [Iterable] of [Model.CalendarEntry] objects associated with
   * contact specified in the parameters.
   */
  Future<Iterable<Model.CalendarEntry>> list(Model.Owner owner,
          {bool deleted: false}) {
    final String sql = '''
SELECT 
  entry.id, 
  entry.start, 
  entry.stop, 
  entry.message,
  r.reception_id,
  c.contact_id
FROM 
  calendar_events entry
LEFT JOIN reception_calendar r ON r.event_id = entry.id
LEFT JOIN contact_calendar c ON c.event_id = entry.id
WHERE
  ${deleted ? '' : 'NOT'} deleted
AND 
  ${_ownerField(owner)} = @ownerID;
''';

    Map parameters = {'ownerID' : _ownerId(owner)};

    return _connection
        .query(sql, parameters)
        .then((rows) => (rows as Iterable).map(_rowToCalendarEntry))
        .catchError((error, stackTrace) {
      log.severe('Query failed! SQL Statement: $sql');
      log.severe('parameters: $parameters');
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    });
          }

  Future<Iterable<Model.CalendarEntryChange>> changes(int entryID) {
    String sql = '''
    SELECT 
      user_id, 
      updated_at,
      last_entry,
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

    Map parameters = {'entryID': entryID};
    return _connection
        .query(sql, parameters)
        .then((Iterable rows) => rows.map(_rowToCalendarEventChange));
  }

  /**
   * NOTE: This is potentially inefficient, as it may compute and order every
   *   row associated with eventID. The primary gain from this function, however
   *   would be easy access to the latest change from the client.
   */
  Future<Model.CalendarEntryChange> latestChange(int entryID) {
    String sql = '''
    SELECT 
      user_id, 
      updated_at,
      last_entry,
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

    Map parameters = {'entryID': entryID};
    return _connection.query(sql, parameters).then((Iterable rows) =>
        rows.length > 0
            ? _rowToCalendarEventChange(rows.first)
            : throw new Storage.NotFound('entryID:$entryID'));
  }

  /**
   * Removes a single [Model.CalendarEntry] from the database based
   * on [eventID].
   *
   * Contact Calendar entry associations will be deleted by CASCADE rule in
   * the database.
   */
  Future purge(entryId) {
    String sql = '''
  DELETE FROM 
     calendar_events 
  WHERE 
    id     = @eventID''';

    Map parameters = {'eventID': entryId};

    return _connection
        .execute(sql, parameters)
        .then((int rowsAffected) => rowsAffected > 0
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
}
