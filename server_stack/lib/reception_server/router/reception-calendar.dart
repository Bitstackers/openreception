part of receptionserver.router;

abstract class ReceptionCalendar {
  
  static final Logger log = new Logger ('$libraryName.ReceptionCalendar');

  /**
   * Lists every calendar event associated with reception identified by [receptionID].
   */
  static void list(HttpRequest request) {
    int receptionID = pathParameter(request.uri, 'reception');

    db.ReceptionCalendar.list(receptionID).then((Iterable<Model.CalendarEntry> event) {
      writeAndClose(request, JSON.encode(event.toList(growable: false)));
    }).catchError((error, stackTrace) {
      log.severe(error, stackTrace);  
      serverError(request, error.toString());
    });
  }

  /**
   * Response handler for creating a new calendar event for associated with
   * the reception.
   */
  static void create(HttpRequest request) {
    int receptionID = pathParameter(request.uri, 'reception');

    if (receptionID == Model.Reception.noID) {
      clientError(request, JSON.encode
          ({'error' : 'Refusing to create event with no reception'}));
      return;
    }

    extractContent(request).then((String content) {
      Model.CalendarEntry newEntry;

      try {
        Map serializedEntry = JSON.decode(content);
        newEntry = new Model.CalendarEntry.fromMap(serializedEntry);
      } catch (error) {

        Map response = {
          'status': 'bad request',
          'description': 'passed message argument is too long, missing or invalid',
          'error': error.toString()
        };
        clientError(request, JSON.encode(response));
        return;
      }

      db.ReceptionCalendar.createEvent(newEntry.receptionID, newEntry).then((Model.CalendarEntry savedEntry) {
        Event.CalendarEvent event = new Event.ReceptionCalendarEntryCreate(savedEntry); 
        
        Notification.broadcastEvent(event);

        //Echo created event back.
        writeAndClose(request, JSON.encode(savedEntry));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        serverError(request, 'Failed to store event in database');
      });
    });
  }

  static void update(HttpRequest request) {
    int receptionID = pathParameter(request.uri, 'reception');
    int eventID = pathParameter(request.uri, 'event');

    extractContent(request).then((String content) {
      Model.CalendarEntry entry;

      try {
        Map serializedEntry = JSON.decode(content);
        entry = new Model.CalendarEntry.fromMap(serializedEntry);        
        
      } catch (error) {
        request.response.statusCode = 400;
        Map response = {
          'status': 'bad request',
          'description': 'passed message argument is too long, missing or invalid',
          'error': error.toString()
        };
        clientError(request, JSON.encode(response));
        return;
      }

      db.ReceptionCalendar.exists(receptionID: receptionID, eventID: eventID).then((bool eventExists) {
        if (!eventExists) {
          notFound(request, {
            'error': 'not found'
          });
          return;
        }
        db.ReceptionCalendar.updateEvent(receptionID, entry).then((int changeCount) {
          
          if (changeCount == 0) {
            notFound(request, {
              'error': 'not found'
            });
            return;
          }
          
          Event.CalendarEvent event = new Event.ReceptionCalendarEntryUpdate (entry); 
          
          Notification.broadcastEvent(event);

          writeAndClose(request, JSON.encode(entry));
        }).catchError((onError) {
          serverError(request, 'Failed to update event in database');
        });
      }).catchError((onError) {
        serverError(request, 'Failed to execute database query');
      });
    }).catchError((onError) {
      serverError(request, 'Failed to extract client request');
    });
  }

  static void remove(HttpRequest request) {
    int receptionID = pathParameter(request.uri, 'reception');
    int eventID = pathParameter(request.uri, 'event');

    db.ReceptionCalendar.exists(receptionID: receptionID, eventID: eventID).then((bool eventExists) {
      if (!eventExists) {
        notFound(request, {
          'error': 'not found'
        });
        return;
      }

      db.ReceptionCalendar.removeEvent(receptionID, eventID).then((int changeCount) {
        if (changeCount == 0) {
          notFound(request, {
            'error': 'not found'
          });
          return;
        }
        
        Model.CalendarEntry dummy = new Model.CalendarEntry.forReception(receptionID)
          ..ID = eventID
          ..beginsAt = new DateTime.fromMillisecondsSinceEpoch(0)
          ..until = new DateTime.fromMillisecondsSinceEpoch(0)
          ..content = '';
        Event.CalendarEvent event = new Event.ReceptionCalendarEntryDelete (dummy); 
        
        Notification.broadcastEvent(event);

        writeAndClose(request, JSON.encode({
          'status': 'ok',
          'description': 'Event deleted'
        }));
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        serverError(request, 'Failed to removed event from database');
      });
    }).catchError((onError) {
      serverError(request, 'Failed to execute database query');
    });
  }

  static void get(HttpRequest request) {
    int receptionID = pathParameter(request.uri, 'reception');
    int eventID = pathParameter(request.uri, 'event');

    db.ReceptionCalendar.getEvent(receptionID: receptionID, eventID: eventID).then((Model.CalendarEntry event) {
      if (event == null) {
        notFound(request, {
          'description': 'No calendar event found with ID $eventID'
        });
      } else {
        writeAndClose(request, JSON.encode(event));
      }
    }).catchError((onError) {
      serverError(request, 'Failed to execute database query');
    });
  }

}
