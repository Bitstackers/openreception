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

part of openreception.reception_server.router;

abstract class ReceptionCalendar {
  static final Logger log = new Logger('$libraryName.ReceptionCalendar');

  /**
   *
   */
  static Future<shelf.Response> listChanges(shelf.Request request) {
    final int entryID = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return db.ReceptionCalendar
        .changes(entryID)
        .then((Iterable<Map> changesMaps) {
      return new shelf.Response.ok(
          JSON.encode(changesMaps.toList(growable: false)));
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body: error.toString());
    });
  }

  /**
   *
   */
  static Future<shelf.Response> latestChange(shelf.Request request) {
    final int entryID = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return db.ReceptionCalendar.latestChange(entryID).then((Map change) {
      return new shelf.Response.ok(JSON.encode(change));
    }).catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new shelf.Response.notFound(JSON.encode({
          'description': 'No changes found for entry '
              'with ID $entryID'
        }));
      }
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body: error.toString());
    });
  }

  /**
   * Lists every calendar event associated with reception identified by
   * [receptionID].
   */
  static Future<shelf.Response> list(shelf.Request request) {
    final int receptionID =
        int.parse(shelf_route.getPathParameter(request, 'rid'));

    return db.ReceptionCalendar
        .list(receptionID)
        .then((Iterable<Model.CalendarEntry> event) {
      return new shelf.Response.ok(JSON.encode(event.toList(growable: false)));
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body: error.toString());
    });
  }

  /**
   * Response handler for creating a new calendar event for associated with
   * the reception.
   */
  static Future create(shelf.Request request) {
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    Model.User user;

    return _authService
        .userOf(_tokenFrom(request))
        .then((Model.User fetchedUser) => user = fetchedUser)
        .then((_) => request.readAsString().then((String content) {
      Model.CalendarEntry entry;

      try {
        Map data = JSON.decode(content);
        entry = new Model.CalendarEntry.fromMap(data);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed message argument is too long, '
              'missing or invalid',
          'error': error.toString()
        };

        return new shelf.Response(400, body: JSON.encode(response));
      }

      return db.ReceptionCalendar
          .createEntry(entry, user)
          .then((Model.CalendarEntry createdEvent) {
        Event.CalendarChange changeEvent = new Event.CalendarChange(entry.ID,
            entry.contactID, entry.receptionID,
            Event.CalendarEntryState.CREATED);

        log.finest('Created event for rid:${receptionID}');

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(entry));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to store event in database');
      });
    })).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to extract client request');
    });
  }

  /**
   * TODO: remove the reception ID from router.
   */
  static Future update(shelf.Request request) {
    int eventID = int.parse(shelf_route.getPathParameter(request, 'eid'));

    Model.User user;

    return _authService
        .userOf(_tokenFrom(request))
        .then((Model.User fetchedUser) => user = fetchedUser)
        .then((_) => request.readAsString().then((String content) {
      Model.CalendarEntry entry;

      try {
        Map data = JSON.decode(content);
        entry = new Model.CalendarEntry.fromMap(data);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed message argument '
              'is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response(400, body: JSON.encode(response));
      }

      return db.ReceptionCalendar.updateEntry(entry, user).then((_) {
        Event.CalendarChange changeEvent = new Event.CalendarChange(entry.ID,
            entry.contactID, entry.receptionID,
            Event.CalendarEntryState.UPDATED);

        _notification.broadcastEvent(changeEvent);

        return new shelf.Response.ok(JSON.encode(entry));
      }).catchError((error, stackTrace) {
        if (error is Storage.NotFound) {
          return new shelf.Response.notFound(
              'Event with id $eventID not found');
        }

        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(
            body: 'Failed to update event in database');
      });
    })).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to execute database query');
    });
  }

  static Future remove(shelf.Request request) {
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    int entryID = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return db.ReceptionCalendar.removeEntry(entryID).then((_) {
      Event.CalendarChange changeEvent = new Event.CalendarChange(entryID,
          Model.Contact.noID, receptionID, Event.CalendarEntryState.DELETED);

      _notification.broadcastEvent(changeEvent);
      return new shelf.Response.ok(
          JSON.encode({'status': 'ok', 'description': 'Event deleted'}));
    }).catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new shelf.Response.notFound(JSON.encode({
          'description': 'No calendar event '
              'found with ID $entryID'
        }));
      }
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to execute database query');
    });
  }

  static Future get(shelf.Request request) {
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    int entryID = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return db.ReceptionCalendar
        .get(receptionID, entryID)
        .then((Model.CalendarEntry event) =>
            new shelf.Response.ok(JSON.encode(event)))
        .catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new shelf.Response.notFound(JSON.encode({
          'description': 'No calendar event '
              'found with ID $entryID'
        }));
      }
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to execute database query');
    });
  }
}
