part of contactserver.router;

abstract class ContactCalendar {

  static const String className = '${libraryName}.ContactCalendar';

  static void create(HttpRequest request) {

    const String context = '${className}.create';

    int contactID   = pathParameter(request.uri, 'contact');
    int receptionID = pathParameter(request.uri, 'reception');

    extractContent(request).then((String content) {
      Map data;

      print (content);

      try {
        data = JSON.decode(content);
      }
      catch(error) {
        request.response.statusCode = 400;
        Map response = {'status'     : 'bad request',
                        'description': 'passed message argument is too long, missing or invalid',
                        'error'      : error.toString()};
        clientError(request, JSON.encode(response));
        return;

      }
      print (data);

      db.ContactCalendar.createEvent(contactID        : contactID,
                                     receptionID      : receptionID,
                                     event            : data)
        .then((_) {
          logger.debugContext('Created event for ${contactID}@${receptionID}', context);

          Notification.broadcast (
              {'event'         : 'contactCalendarEventCreated',
               'calendarEvent' :  {
                 'contactID'   : contactID,
                 'receptionID' : receptionID
               }
              });
          writeAndClose(request, JSON.encode(data));
        }).catchError((onError) {
          serverError(request, 'Failed to store event in database');
        });
    }).catchError((onError) {
      serverError(request, 'Failed to extract client request');
    });
  }

  static void update(HttpRequest request) {
    int contactID   = pathParameter(request.uri, 'contact');
    int receptionID = pathParameter(request.uri, 'reception');
    int eventID     = pathParameter(request.uri, 'event');

    extractContent(request).then((String content) {
      Map data;

      try {
        data = JSON.decode(content);
      }
      catch(error) {
        request.response.statusCode = 400;
        Map response = {'status'     : 'bad request',
                        'description': 'passed message argument is too long, missing or invalid',
                        'error'      : error.toString()};
        clientError(request, JSON.encode(response));
        return;
      }

      db.ContactCalendar.exists(contactID        : contactID,
                                receptionID      : receptionID,
                                eventID          : eventID).then((bool eventExists) {
        if (!eventExists) {
          notFound(request, {'error' : 'not found'});
          return;
        }
        db.ContactCalendar.updateEvent(contactID        : contactID,
                                     receptionID      : receptionID,
                                     eventID          : eventID,
                                     event            : data)
        .then((_) {
          Notification.broadcast (
              {'event'         : 'contactCalendarEventUpdated',
               'calendarEvent' :  {
                 'contactID'   : contactID,
                 'receptionID' : receptionID
               }
              });
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
    int contactID   = pathParameter(request.uri, 'contact');
    int receptionID = pathParameter(request.uri, 'reception');
    int eventID     = pathParameter(request.uri, 'event');

    db.ContactCalendar.exists(contactID        : contactID,
                              receptionID      : receptionID,
                              eventID          : eventID).then((bool eventExists) {
      if (!eventExists) {
        notFound(request, {'error' : 'not found'});
        return;
      }

      db.ContactCalendar.removeEvent(contactID        : contactID,
                                     receptionID      : receptionID,
                                     eventID          : eventID)
          .then((_) {
        Notification.broadcast (
            {'event'         : 'contactCalendarEventDeleted',
             'calendarEvent' :  {
               'contactID'   : contactID,
               'receptionID' : receptionID
             }
            });
            writeAndClose(request, JSON.encode({'status' : 'ok',
                                                'description' : 'Event deleted'}));
          }).catchError((onError) {
          serverError(request, 'Failed to removed event from database');
        });
    }).catchError((onError) {
      serverError(request, 'Failed to execute database query');
    });
  }

  static void get(HttpRequest request) {
    int contactID   = pathParameter(request.uri, 'contact');
    int receptionID = pathParameter(request.uri, 'reception');
    int eventID     = pathParameter(request.uri, 'event');

    db.ContactCalendar.getEvent(contactID        : contactID,
                                receptionID      : receptionID,
                                eventID          : eventID)
      .then((Map event) {
        if (event == null) {
          notFound(request, {'description' : 'No calendar event found with ID $eventID'});
        } else {
          writeAndClose(request, JSON.encode({'event' : event}));
        }
      }).catchError((onError) {
        serverError(request, 'Failed to execute database query');
      });
  }

}