part of messageserver.router;

abstract class Message {

  static final Logger log = new Logger ('$libraryName.Message');

  static const String className = '${libraryName}.Message';

  /**
   * HTTP Request handler for returning a single message resource.
   */
  static void get(HttpRequest request) {
    int messageID  = pathParameter(request.uri, 'message');

    messageStore.get(messageID)
      .then((Model.Message message) {
        writeAndClose(request, JSON.encode(message));
      })
      .catchError((error, stackTrace) {

      if (error is Storage.NotFound) {
        notFound(request, {'description' : error.message});
      } else {
        serverError(request, '$error : $stackTrace');
      }
    });
  }


  /**
   * HTTP Request handler for updating a single message resource.
   */
  static void update(HttpRequest request) {
    final String     token = request.uri.queryParameters['token'];

    AuthService.userOf(token).then((Model.User user) {
      extractContent(request).then((String content) {
        try {
          Model.Message parameterMessage =
              new Model.Message.fromMap(JSON.decode(content))..sender = user;

          return messageStore.save(parameterMessage)
              .then((Model.Message message) {
            if (parameterMessage.ID == Model.Message.noID) {
              Notification.broadcast({'event' : 'messageCreated', 'message' : {'id' : message.ID}});
            } else {
              Notification.broadcast({'event' : 'messageUpdated', 'message' : {'id' : message.ID}});
            }

            writeAndClose(request, JSON.encode(message));
           });

        } catch (error, stackTrace) {
          log.severe(error, stackTrace);
          clientError(request, '$error : $stackTrace');
        }

      }).catchError((error, stackTrace) {
        log.severe('Failed to extract content of request.');
        log.severe (error, stackTrace);
        serverError(request, 'Failed to extract content of request.');
      });
    }).catchError((error, stackTrace) {
      log.severe('Failed to perform user lookup.');
      log.severe (error, stackTrace);
      serverError(request, 'Failed to perform user lookup.');
    });
  }

  /**
   * Lists the most recently stored messages. Limits on number of fetched messages
   * are enforced by the persistant storage layer.
   */
  static void listNewest (HttpRequest request) {
    messageStore.list()
      .then ((List<Model.Message> messages) =>
        writeAndClose(request, JSON.encode(messages)))
      .catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        serverError(request, error.toString());
    });
  }

  /**
   * Builds a list of previously stored messages, filtering by the
   * parameters passed in the [queryParameters] of the request.
   */
  static void list (HttpRequest request) {
    Model.MessageFilter filter = new Model.MessageFilter.empty();

    filter.upperMessageID = pathParameter(request.uri, 'list');

    if (request.uri.queryParameters.containsKey('filter')) {
      try {

        Map map = JSON.decode(request.uri.queryParameters['filter']);

        filter..messageState   = map ['state']
              ..contactID      = map ['contact_id']
              ..receptionID    = map ['reception_id']
              ..userID         = map ['user_id']
              ..limitCount     = map ['limit']
              ..upperMessageID = map ['upper_message_id'];
      } catch (error, stacktrace) {
        clientError(request, 'Bad filter');
        return;
      }
    }

    messageStore.list(filter : filter)
      .then ((List<Model.Message> messages) {
        writeAndClose(request, JSON.encode(messages));})
      .catchError((error, stackTrace) {
        serverError(request, error.toString());
        log.severe (error, stackTrace);
    });
  }

  /**
   * Enqueues a messages for dispathing via the transport layer specified in
   * the endpoints belonging to the message recipients.
   */
  static void send (HttpRequest request) {

    final String token   = request.uri.queryParameters['token'];

    AuthService.userOf(token).then((Model.User user) {
      extractContent(request).then((String content) {

        try {
          Model.Message message = new Model.Message.fromMap(JSON.decode(content))..sender = user;
          return messageStore.save(message)
            .then((_) => messageStore.enqueue(message)
              .then((_) {
                writeAndClose(request, '{"description" : "Saved and enqueued message." , "id" : ${message.ID} }');
              })
            );
        } catch (error, stackTrace) {
          log.severe(error, stackTrace);
          clientError(request, '$error : $stackTrace');
        }

      }).catchError((error, stackTrace) {
        log.severe('Failed to extract content of request.');
        log.severe (error, stackTrace);
        serverError(request, 'Failed to extract content of request.');
      });
    }).catchError((error, stackTrace) {
      log.severe('Failed to perform user lookup.');
      log.severe (error, stackTrace);
      serverError(request, 'Failed to perform user lookup.');
    });
   }


  /**
   * Persistently stores a messages. If the message already exists, the
   * message - and the it's contents - are replaced by the one passed by the client.
   */
  static void save (HttpRequest request) {

    final String context = '${className}.save';
    final String token   = request.uri.queryParameters['token'];

    AuthService.userOf(token).then((Model.User user) {
      extractContent(request).then((String content) {

        try {
          Model.Message message = new Model.Message.fromMap(JSON.decode(content))..sender = user;
          Notification.broadcast({'event' : 'messageCreated', 'message' : {'id' : message.ID}});

          if (message.ID != Model.Message.noID) {
            clientError(request, 'Refusing to re-create existing message. '
                                 'Remove messageID or use the PUT method instead.');
            return;
          }


          messageStore.save(message)
              .then((Model.Message message) => writeAndClose(request, JSON.encode(message)));

        } catch (error, stackTrace) {
          log.warning (error, stackTrace);
          clientError(request, '$error : $stackTrace');
        }

      }).catchError((error, stackTrace) {
        log.severe('Failed to extract content of request.');
        log.severe (error, stackTrace);
        serverError(request, 'Failed to extract content of request.');
      });
    }).catchError((error, stackTrace) {
      log.severe('Failed to perform user lookup.');
      log.severe (error, stackTrace);
      serverError(request, 'Failed to perform user lookup.');
    });
  }
}

