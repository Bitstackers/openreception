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

  /**
   * Retrieve a CalendarEvent from the database store. Echoes back the inserted
   * CalendarEntry with the database event ID set.
   *
   * TODO: Implement the distribution list.
   */
  Future<Model.CalendarEntry> _createInContact(
      Model.CalendarEntry entry, Model.User user) {
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

    Map parameters = {
      'receptionID': entry.receptionID,
      'contactID': entry.contactID,
      'start': entry.start,
      'end': entry.stop,
      'userID': user.ID,
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

  Future<Model.CalendarEntry> _createInReception(
      Model.CalendarEntry entry, Model.User user) {
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

    Map parameters = {
      'receptionID': entry.receptionID,
      'start': entry.start,
      'end': entry.stop,
      'userID': user.ID,
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
   * [receptionID], [contactID] and [eventID] members of [entry].
   *
   * TODO: Take the distribution list into accout.
   */
  Future<Model.CalendarEntry> _updateInContact(
      Model.CalendarEntry entry, Model.User user,
      {Map distributionList: null}) {
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

    Map parameters = {
      'eventID': entry.ID,
      'distributionList': distributionList,
      'start': entry.start,
      'stop': entry.stop,
      'content': entry.content,
      'userID': user.ID
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

  Future<int> _updateInReception(Model.CalendarEntry entry, Model.User user) {
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

    Map parameters = {
      'eventID': entry.ID,
      'start': entry.start,
      'stop': entry.stop,
      'content': entry.content,
      'userID': user.ID
    };

    return _connection
        .execute(sql, parameters)
        .then((int rowsAffected) => rowsAffected > 0
            ? null
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
   * Retrieve a single [Model.CalendarEntry] from the database based on
   * [entryID].
   * Returns null if no entry is found.
   */
  Future<Model.CalendarEntry> getByContact(
      int contactID, int receptionID, int entryID) {
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

    Map parameters = {
      'receptionID': receptionID,
      'contactID': contactID,
      'entryID': entryID
    };

    return _connection
        .query(sql, parameters)
        .then((rows) => rows.length > 0
            ? _rowToContactCalendarEntry(rows.first)
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
   * Retrieve a single [Model.CalendarEntry] from the database based
   * on [entryID].
   * Returns null if no entry is found.
   */
  Future<Model.CalendarEntry> getInReception(int entryID) {
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
AND 
  entry.id     = @entryID
LIMIT 1;
''';

    Map parameters = {'entryID': entryID};

    return _connection
        .query(sql, parameters)
        .then((rows) => rows.length > 0
            ? _rowToReceptionCalendarEntry(rows.first)
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
  Future<Iterable<Model.CalendarEntry>> _listByContact(
      int receptionID, int contactID) {
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

    Map parameters = {'receptionID': receptionID, 'contactID': contactID};

    return _connection
        .query(sql, parameters)
        .then((rows) => (rows as List).map(_rowToContactCalendarEntry))
        .catchError((error, stackTrace) {
      log.severe('Query failed! SQL Statement: $sql');
      log.severe('parameters: $parameters');
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Returns an [Iterable] of [Model.CalendarEntry] objects associated with
   * reception specified in the parameters.
   */
  Future<Iterable<Model.CalendarEntry>> _listByReception(int receptionID) {
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

    Map parameters = {'receptionID': receptionID};

    return _connection
        .query(sql, parameters)
        .then((rows) => (rows as List).map(_rowToReceptionCalendarEntry))
        .catchError((error, stackTrace) {
      log.severe('Query failed! SQL Statement: $sql');
      log.severe('parameters: $parameters');
      log.severe(error, stackTrace);
      return new Future.error(error, stackTrace);
    });
  }

  /**
   * Retrieve a single [Model.CalendarEntry] from the database based
   * on [entryID]. It does not fetch the owner, which needs to fetched
   * afterwards.
   * Throws [NotFound] exeception if no entry is found.
   */
  Future<Model.CalendarEntry> get(int entryID) {
    String sql = '''
SELECT 
  entry.id, 
  entry.start, 
  entry.stop, 
  entry.message, 
FROM 
  reception_calendar owner
WHERE 
  entry.id     = @entryID;
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
  Future<Model.CalendarEntry> create(Model.CalendarEntry entry, Model.User user,
          {Map distributionList: null}) =>
      entry.owner.contactId != Model.Contact.noID
          ? _createInContact(entry, user)
          : _createInReception(entry, user);

  /**
   * Updates a single [Model.CalendarEntry] from the database based on
   * [owner] of the [entry].
   *
   * TODO: Take the distribution list into accout.
   */
  Future<Model.CalendarEntry> update(Model.CalendarEntry entry, Model.User user,
          {Map distributionList: null}) =>
      entry.owner.contactId != Model.Contact.noID
          ? _updateInContact(entry, user)
          : _updateInReception(entry, user);

  /**
   * Removes a single [Model.CalendarEntry] from the database based on
   * [receptionID], [contactID] and [eventID].
   *
   * Contact Calendar entry associations will be deleted by CASCADE rule in
   * the database.
   */
  Future remove(int contactID, int receptionID, int eventID) {
    String sql = '''
  DELETE FROM 
     calendar_events 
  WHERE 
    id     = @eventID
''';

    Map parameters = {'eventID': eventID};

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
   * Retrieve a single [Model.CalendarEntry] from the database based
   * on [entryId].
   * Returns null if no entry is found.
   */
  Future<Model.CalendarEntry> getInContact(int entryId) {
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
  entry.id     = @entryID
LIMIT 1;
''';

    Map parameters = {'entryID': entryId};

    return _connection
        .query(sql, parameters)
        .then((rows) => rows.length > 0
            ? _rowToContactCalendarEntry(rows.first)
            : new Future.error(new Storage.NotFound('eid:$entryId')))
        .catchError((error, stackTrace) {
      if (error is! Storage.NotFound) {
        log.severe('Query failed! SQL Statement: $sql');
        log.severe('parameters: $parameters');
        log.severe(error, stackTrace);
      }
      return new Future.error(error, stackTrace);
    });
  }

  Future<Iterable<Model.CalendarEntry>> list(Model.Owner owner) =>
      owner.contactId != Model.Contact.noID
          ? _listByContact(owner.receptionId, owner.contactId)
          : _listByReception(owner.receptionId);

  Future<Iterable<Model.CalendarEntryChange>> changes(int entryID) {
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
    return _connection.query(sql, parameters).then(
        (Iterable rows) => rows.length > 0
            ? _rowToCalendarEventChange(rows.first)
            : throw new Storage.NotFound('entryID:$entryID'));
  }
}
