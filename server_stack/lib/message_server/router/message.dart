part of messageserver.router;

abstract class Message {

  static final Logger log = new Logger ('$libraryName.Message');

  static const String className = '${libraryName}.Message';

  /**
   * HTTP Request handler for returning a single message resource.
   */
  static Future<shelf.Response> get(shelf.Request request) {
    int messageID  = int.parse(shelf_route.getPathParameter(request, 'mid'));

    return _messageStore.get(messageID)
      .then((Model.Message message) {
        return new shelf.Response.ok (JSON.encode(message));
      })
      .catchError((error, stackTrace) {

        if (error is Storage.NotFound) {
          return new shelf.Response.notFound
              (JSON.encode({'description' : error.message}));
        } else {
          log.severe('Failed to retrieve message with '
                     'ID $messageID', error, stackTrace);
          return new shelf.Response.internalServerError
              (body : '$error : $stackTrace');
        }
      });
  }


  /**
   * HTTP Request handler for updating a single message resource.
   */
  static Future<shelf.Response> update(shelf.Request request) {

    return _authService.userOf(_tokenFrom (request)).then((Model.User user) {
      return request.readAsString().then((String content) {
        try {
          Model.Message parameterMessage =
              new Model.Message.fromMap(JSON.decode(content))..sender = user;

          return _messageStore.save(parameterMessage)
              .then((Model.Message message) {
            if (parameterMessage.ID == Model.Message.noID) {
              Event.MessageChange event =
                new Event.MessageChange
                  (message.ID, Event.MessageChangeState.CREATED);

              _notification.broadcastEvent(event);
            } else {
              Event.MessageChange event =
                new Event.MessageChange
                  (message.ID, Event.MessageChangeState.UPDATED);

              _notification.broadcastEvent(event);
            }

            return new shelf.Response.ok(JSON.encode(message));
           });

        } catch (error, stackTrace) {
          log.warning
            ('Failed to parse message in POST body', error, stackTrace);
          return new shelf.Response
            (400, body : 'Failed to parse message in POST body');

        }

      }).catchError((error, stackTrace) {
        log.severe('Failed to extract content of request.', error, stackTrace);
        return new shelf.Response.internalServerError
          (body : 'Failed to extract content of request.');
      });
    }).catchError((error, stackTrace) {
      log.severe('Failed to perform user lookup.', error, stackTrace);
      return new shelf.Response.internalServerError
        (body : 'Failed to perform user lookup.');
    });
  }

  /**
   * Lists the most recently stored messages. Limits on number of fetched messages
   * are enforced by the persistant storage layer.
   */
  static Future<shelf.Response> listNewest (shelf.Request request) {
    return _messageStore.list()
      .then ((Iterable<Model.Message> messages) =>
        new shelf.Response.ok(JSON.encode(messages.toList())))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.internalServerError
          (body : error.toString());
    });
  }

  /**
   * Builds a list of previously stored messages, filtering by the
   * parameters passed in the [queryParameters] of the request.
   */
  static Future<shelf.Response> list (shelf.Request request) {
    Model.MessageFilter filter = new Model.MessageFilter.empty();
    int messageID  = int.parse(shelf_route.getPathParameter(request, 'mid'));


    filter.upperMessageID = messageID;

    if (shelf_route.getPathParameters(request).containsKey('filter')) {
      try {
        Map map = JSON.decode(shelf_route.getPathParameter(request, 'filter'));

        filter..messageState   = map ['state']
              ..contactID      = map ['contact_id']
              ..receptionID    = map ['reception_id']
              ..userID         = map ['user_id']
              ..limitCount     = map ['limit']
              ..upperMessageID = map ['upper_message_id'];
      } catch (error, stackTrace) {
        log.warning(error, stackTrace);
        return new Future.value(new shelf.Response(400, body : 'Bad filter'));
      }
    }

    return _messageStore.list(filter : filter)
      .then ((Iterable<Model.Message> messages) =>
        new shelf.Response.ok (JSON.encode(messages.toList())))

      .catchError((error, stackTrace) {
        log.severe (error, stackTrace);
        return new shelf.Response.internalServerError
         (body :  error.toString());
    });
  }

  /**
   * Enqueues a messages for dispathing via the transport layer specified in
   * the endpoints belonging to the message recipients.
   */
  static Future<shelf.Response> send (shelf.Request request) {

    return _authService.userOf(_tokenFrom (request)).then((Model.User user) {
      return request.readAsString().then((String content) {
        Model.Message message;

        try {
          message = new Model.Message.fromMap(JSON.decode(content))
            ..sender = user;

          if ([Model.Message.noID, null].contains(message.ID)) {
            return new shelf.Response(400, body : 'Invalid message ID');
          }
        } catch (error, stackTrace) {
          log.severe(error, stackTrace);
          return new shelf.Response(400, body : '$error : $stackTrace');
        }

        return _messageStore.enqueue(message)
            .then((Model.MessageQueueItem queueItem) {

          Event.MessageChange event =
            new Event.MessageChange
              (message.ID, Event.MessageChangeState.UPDATED);

          _notification.broadcastEvent(event);
              Event.MessageChange updateEvent =
                new Event.MessageChange
                  (message.ID, Event.MessageChangeState.UPDATED);

              _notification.broadcastEvent(updateEvent);


              return new shelf.Response.ok (JSON.encode(queueItem));
              });

      }).catchError((error, stackTrace) {
        log.severe('Failed to extract content of request.', error, stackTrace);
        return new shelf.Response.internalServerError
          (body : 'Failed to extract content of request.');
      });
    }).catchError((error, stackTrace) {
      log.severe('Failed to perform user lookup.', error, stackTrace);
      return new shelf.Response.internalServerError
        (body : 'Failed to perform user lookup.');
    });
   }


  /**
   * Persistently stores a messages. If the message already exists, the
   * message - and the it's contents - are replaced by the one passed by the client.
   */
  static Future<shelf.Response> save (shelf.Request request) {

    return _authService.userOf(_tokenFrom (request)).then((Model.User user) {
      return request.readAsString().then((String content) {

        try {
          Model.Message message =
              new Model.Message.fromMap(JSON.decode(content))..sender = user;

          if (message.ID != Model.Message.noID) {
            return new shelf.Response(400, body :
              'Refusing to re-create existing message. '
              'Remove messageID or use the PUT method instead.');
          }


          return _messageStore.save(message)
            .then((Model.Message message) {
              Event.MessageChange event = new Event.MessageChange
                  (message.ID, Event.MessageChangeState.UPDATED);

              _notification.broadcastEvent(event);

              return new shelf.Response.ok(JSON.encode(message));
            });


        } catch (error, stackTrace) {
          log.warning (error, stackTrace);
          return new shelf.Response(400, body : '$error : $stackTrace');
        }

      }).catchError((error, stackTrace) {
        log.severe('Failed to extract content of request.', error, stackTrace);
        return new shelf.Response.internalServerError
          (body : 'Failed to extract content of request.');
      });
    }).catchError((error, stackTrace) {
      log.severe('Failed to perform user lookup.', error, stackTrace);
      return new shelf.Response.internalServerError
        (body : 'Failed to perform user lookup.');
    });
  }
}

