part of receptionserver.router;

abstract class ReceptionCalendar {

  /**
   * Lists every calendar event associated with reception identified by [receptionID].
   */
  static void list(HttpRequest request) {
    int receptionID = pathParameter(request.uri, 'reception');

    db.ReceptionCalendar.list(receptionID).then((List<Model.CalendarEvent> event) {
      writeAndClose(request, JSON.encode(event));
    }).catchError((error) {
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
      Map data;

      try {
        data = JSON.decode(content);



      } catch (error) {

        Map response = {
          'status': 'bad request',
          'description': 'passed message argument is too long, missing or invalid',
          'error': error.toString()
        };
        clientError(request, JSON.encode(response));
        return;
      }

      db.ReceptionCalendar.createEvent(receptionID: receptionID, event: data).then((_) {
        Map event = {
          'event': 'receptionCalendarEventCreated',
          'calendarEvent': {
            'receptionID': receptionID
          }
        };
        Notification.broadcast(event);

        //Echo created event back.
        writeAndClose(request, JSON.encode(data));
      }).catchError((onError) {
        serverError(request, 'Failed to store event in database');
      });
    });
  }

  static void update(HttpRequest request) {
    int receptionID = pathParameter(request.uri, 'reception');
    int eventID = pathParameter(request.uri, 'event');

    extractContent(request).then((String content) {
      Map data;

      try {
        data = JSON.decode(content);
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
        db.ReceptionCalendar.updateEvent(receptionID: receptionID, eventID: eventID, event: data).then((_) {
          Map event = {
            'event': 'receptionCalendarEventUpdated',
            'calendarEvent': {
              'eventID': eventID,
              'receptionID': receptionID
            }
          };
          Notification.broadcast(event);
          writeAndClose(request, JSON.encode(data));
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

      db.ReceptionCalendar.removeEvent(receptionID: receptionID, eventID: eventID).then((_) {
        Map event = {
          'event': 'receptionCalendarEventDeleted',
          'calendarEvent': {
            'eventID': eventID,
            'receptionID': receptionID
          }
        };
        Notification.broadcast(event);

        writeAndClose(request, JSON.encode({
          'status': 'ok',
          'description': 'Event deleted'
        }));
      }).catchError((onError) {
        serverError(request, 'Failed to removed event from database');
      });
    }).catchError((onError) {
      serverError(request, 'Failed to execute database query');
    });
  }

  static void get(HttpRequest request) {
    int receptionID = pathParameter(request.uri, 'reception');
    int eventID = pathParameter(request.uri, 'event');

    db.ReceptionCalendar.getEvent(receptionID: receptionID, eventID: eventID).then((Model.CalendarEvent event) {
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
