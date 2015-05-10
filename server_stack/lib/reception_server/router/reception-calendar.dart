part of receptionserver.router;

abstract class ReceptionCalendar {

  /**
   * Lists every calendar event associated with reception identified by [receptionID].
   */
  static Future<shelf.Response> list(shelf.Request request) {
    final int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    return db.ReceptionCalendar.list(receptionID)
      .then((Iterable<Model.CalendarEntry> event) {
        return new shelf.Response.ok(JSON.encode(event.toList(growable: false)));
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);  
        return new shelf.Response.internalServerError(body : error.toString());
    });
  }

  /**
   * Response handler for creating a new calendar event for associated with
   * the reception.
   */
  static Future<shelf.Response> create(shelf.Request request) {
    final int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));

    if (receptionID == Model.Reception.noID) {
      return new Future.value
        (new shelf.Response
          (400 , body: JSON.encode
            ({'error' : 'Refusing to create event with no reception'})));
    }

    return request.readAsString().then((String content) {
      Model.CalendarEntry newEntry;

      try {
        Map data = JSON.decode(content);
        newEntry = new Model.CalendarEntry.fromMap(data);

      } catch (error) {

        Map response = {
          'status': 'bad request',
          'description': 'passed message argument is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response
          (400 , body: JSON.encode(response));
      }

      return db.ReceptionCalendar.createEvent(newEntry.receptionID, newEntry)
        .then((Model.CalendarEntry savedEntry) {
          Event.CalendarEvent event = new Event.ReceptionCalendarEntryCreate(savedEntry); 
        
          Notification.broadcastEvent(event);

          //Echo created event back.
          return new shelf.Response.ok(JSON.encode(savedEntry));
        })
        .catchError((error, stackTrace) {
          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError(body : 'Failed to store event in database');
      });
    });
  }

  static Future<shelf.Response> update(shelf.Request request) {
    final int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    final int eventID = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return request.readAsString().then((String content) {
      Model.CalendarEntry entry;

      try {
        data = JSON.decode(content);
      } catch (error) {
        Map response = {
          'status': 'bad request',
          'description': 'passed message argument is too long, missing or invalid',
          'error': error.toString()
        };
        return new shelf.Response
          (400 , body: JSON.encode(response));
      }

      return db.ReceptionCalendar.exists(receptionID: receptionID, eventID: eventID)
        .then((bool eventExists) {
        if (!eventExists) {
          return new shelf.Response.notFound(JSON.encode({
            'error': 'not found'
          }));
        }

        return db.ReceptionCalendar.updateEvent(receptionID, entry).then((int changeCount) {
          
          if (changeCount == 0) {
            return new shelf.Response.notFound(JSON.encode({'error': 'not found'}));
          }
          
          Event.CalendarEvent event = new Event.ReceptionCalendarEntryUpdate (entry); 
          
          Notification.broadcastEvent(event);

          return new shelf.Response.ok(JSON.encode(entry));
        })
        .catchError((error, stackTrace) {
          log.severe(error, stackTrace);
          return new shelf.Response.internalServerError(body : 'Failed to update event in database');
        });
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(body : 'Failed to execute database query');
      });
    })
    .catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body : 'Failed to extract client request');
    });
  }

  static Future<shelf.Response> remove(shelf.Request request) {
    final int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    final int eventID = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return db.ReceptionCalendar.exists(receptionID: receptionID, eventID: eventID)
      .then((bool eventExists) {
        if (!eventExists) {
          return new shelf.Response.notFound(JSON.encode({'error': 'not found'}));
        }

        return db.ReceptionCalendar.removeEvent(receptionID, eventID).then((int changeCount) {
        if (changeCount == 0) {
          return new shelf.Response.notFound(JSON.encode({'error': 'not found'}));
        }
        
        //TODO: change the events so that they do not contain full event obects.
        Model.CalendarEntry dummy = new Model.CalendarEntry.forReception(receptionID)
          ..ID = eventID
          ..beginsAt = new DateTime.fromMillisecondsSinceEpoch(0)
          ..until = new DateTime.fromMillisecondsSinceEpoch(0)
          ..content = '';
        Event.CalendarEvent event = new Event.ReceptionCalendarEntryDelete (dummy); 
        
        Notification.broadcastEvent(event);

        return new shelf.Response.ok(JSON.encode({
          'status': 'ok',
          'description': 'Event deleted'
        }));
      })
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError(body : 'Failed to removed event from database');
    })
    .catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body : 'Failed to execute database query');
    });
  });
  }

  static Future<shelf.Response> get(shelf.Request request) {
    final int receptionID = int.parse(shelf_route.getPathParameter(request, 'rid'));
    final int eventID = int.parse(shelf_route.getPathParameter(request, 'eid'));

    return db.ReceptionCalendar.getEvent(receptionID: receptionID, eventID: eventID)
      .then((Model.CalendarEntry event) {
      if (event == null) {
        return new shelf.Response.notFound(JSON.encode({
          'description': 'No calendar event found with ID $eventID'
        }));
      } else {
        return new shelf.Response.ok(JSON.encode(event));
      }
    })
    .catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body : 'Failed to execute database query');
    });
  }

}
