part of contactserver.router;

abstract class ContactCalendar {

  static final Logger log = new Logger ('${libraryName}.ContactCalendar');

  static Future create(shelf.Request request) {

    int contactID = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return request.readAsString().then((String content) {

      Model.CalendarEntry entry;

      try {
        Map data = JSON.decode(content);
        entry = new Model.CalendarEntry.fromMap(data);
      }
      catch(error) {
        Map response = {'status'     : 'bad request',
                        'description': 'passed message argument is too long, missing or invalid',
                        'error'      : error.toString()};

        return new shelf.Response (400, body : JSON.encode(response));
      }

      return db.ContactCalendar.createEntry(entry)
        .then((Model.CalendarEntry createdEvent) {
          Event.CalendarChange changeEvent =
              new Event.CalendarChange (entry.ID, entry.contactID, entry.receptionID, Event.CalendarEntryState.CREATED);

          log.finest('Created event for ${contactID}@${receptionID}');

          Notification.broadcastEvent (changeEvent);

          return new shelf.Response.ok(JSON.encode(entry));
        }).catchError((error, stackTrace) {
          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError(body : 'Failed to store event in database');
        });
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body : 'Failed to extract client request');
    });
  }

  static Future update(shelf.Request request) {
    int contactID   = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    int eventID     = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return request.readAsString().then((String content) {
      Model.CalendarEntry entry;

      try {
        Map data = JSON.decode(content);
        entry = new Model.CalendarEntry.fromMap(data);
      }
      catch(error) {

        Map response = {'status'     : 'bad request',
                        'description': 'passed message argument is too long, missing or invalid',
                        'error'      : error.toString()};
        return new shelf.Response (400, body : JSON.encode(response));
      }

      return db.ContactCalendar.updateEntry(entry)
        .then((_) {
          Event.CalendarChange changeEvent =
              new Event.CalendarChange (entry.ID, entry.contactID, entry.receptionID, Event.CalendarEntryState.UPDATED);

          Notification.broadcastEvent (changeEvent);

          return new shelf.Response.ok(JSON.encode(entry));
        }).catchError((error, stackTrace) {
          if (error is Storage.NotFound) {
            return new
                shelf.Response.notFound('Event with id $eventID not found');
          }

          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError(body : 'Failed to update event in database');
        });
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(body : 'Failed to execute database query');
      });
  }

  static Future remove(shelf.Request request) {
    int contactID   = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    int eventID     = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return db.ContactCalendar.get (contactID, receptionID, eventID)
      .then((Model.CalendarEntry entry) {
      if (entry == null) {
        return new shelf.Response.notFound(JSON.encode({'error' : 'not found'}));
      }

      return db.ContactCalendar.removeEntry(contactID, receptionID, eventID)
          .then((_) {
        Event.CalendarChange changeEvent =
            new Event.CalendarChange (entry.ID, entry.contactID, entry.receptionID, Event.CalendarEntryState.DELETED);

            Notification.broadcastEvent (changeEvent);
            return new shelf.Response.ok(JSON.encode({'status' : 'ok',
                                                'description' : 'Event deleted'}));
          }).catchError((error, stackTrace) {
           log.severe(error, stackTrace);
           return new shelf.Response.internalServerError(body : 'Failed to removed event from database');
        });
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body : 'Failed to execute database query');
    });
  }

  static Future get(shelf.Request request) {
    int contactID   = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    int eventID     = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return db.ContactCalendar.get(contactID, receptionID, eventID)
      .then((Model.CalendarEntry event) {
        if (event == null) {
          return new shelf.Response.notFound(JSON.encode({'description' : 'No calendar event found with ID $eventID'}));
        } else {
          return new shelf.Response.ok(JSON.encode(event));
        }
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(body : 'Failed to execute database query');
      });
  }

  static Future list(shelf.Request request) {
    int contactID   = int.parse(shelf_route.getPathParameter(request, 'cid'));
    int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return Contact.exists (contactID : contactID, receptionID : receptionID).then((bool exists) {
      if(exists) {
        return db.ContactCalendar.list(receptionID, contactID).then((Iterable<Model.CalendarEntry> entries) {
          return new shelf.Response.ok(JSON.encode(entries.toList()));
        });
      } else {
        return new shelf.Response.notFound(JSON.encode({'description' : 'no such contact ${contactID}@${receptionID}'}));
      }
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body : error.toString());
    });
  }
}