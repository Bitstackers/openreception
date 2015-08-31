part of notificationserver.router;

abstract class Notification {

  static const String className = '$libraryName.Notification';
  static final Logger log       = new Logger(Notification.className);
  static List _stats = [];
  static int _sendCountBuffer = 0;

  static initStats () {

    new Timer.periodic(new Duration(seconds : 1), _tick);
  }

  static _tick(_) {
    if (_stats.length > 60) {
      _stats.removeAt(0);
    }

    _stats.add(_sendCountBuffer);
    _sendCountBuffer = 0;

  }

  static void statistics(HttpRequest request) {
    List retval = [];

    int i = 0;
    _stats.forEach((int num) {
      retval.add([i, num]);
      i++;
    });
    ORhttp.writeAndClose(request, JSON.encode(retval));
  }

  /**
   * Broadcasts a message to every connected websocket.
   */
  static void broadcast(HttpRequest request) {

    ORhttp.extractContent(request).then((String content) {
      Map contentMap = {};
      try {
        contentMap = JSON.decode(content);
      } catch (exeption) {
        ORhttp.clientError(request, "Malformed JSON body");
        return;
      }

      Map result = _broadcast(contentMap);
      ORhttp.writeAndClose(request, JSON.encode(result));
    });
  }

  static Map _broadcast(Map content) {
    int success = 0;
    int failure = 0;

    clientRegistry.keys.map((int uid) {
      return clientRegistry[uid].map((WebSocket ws) {
        try {
          String contentString = JSON.encode(content);

          ws.add(contentString);
          _sendCountBuffer += contentString.codeUnits.length;
          success++;
          return true;
        } catch (error, stackTrace) {
          failure++;
          log.severe ("Failed to send message to client $uid - error: $error");
          log.severe (error, stackTrace);
          return false;
        }
      }).toList();
    }).toList();

    return {
            "status": {
              "success": success,
              "failed": failure
            }
    };
  }

  /**
   * WebSocket registration handling.
   * Registers and un-registers the the websocket in the global registry.
   */
  static _register(WebSocket webSocket, int uid) {
    log.info('New WebSocket connection from uid $uid');

    /// Make sure that there is a list to insert into.
    if (clientRegistry[uid] == null) {
      clientRegistry[uid] = new List<WebSocket>();
    }
    clientRegistry[uid].add(webSocket);

    /// Listen for incoming data. We expect the data to be a JSON-encoded String.
    webSocket.map((string) {
      try {
        return JSON.decode(string);
      } catch (error) {
        return {
          "status": "Malformed content - expected JSON string."
        };
      }
    }).listen((json) {
      log.warning('Client $uid tried to send us a message. This is not supported, echoing back.');
      webSocket.add(JSON.encode(json)); // Echo.

    }, onError: (error, stackTrace) {
      log.severe('Client $uid sent us a very malformed message. $error : ', stackTrace);
      clientRegistry[uid].remove(webSocket);
      webSocket.close(WebSocketStatus.UNSUPPORTED_DATA, "Bad request");
    }, onDone: () {
      log.info('Disconnected WebSocket connection from uid $uid', "handleWebsocket");
      clientRegistry[uid].remove(webSocket);


      Model.ClientConnection conn = new Model.ClientConnection.empty()
        ..userID = uid
        ..connectionCount = clientRegistry[uid].length;
      Event.ClientConnectionState event = new Event.ClientConnectionState(conn);

      _broadcast (event.asMap);
    });
  }

  /**
   * Upgrades an incoming HTTP request to a webSocket and attaches the appropriate event handlers.
   */
  static Future connect(HttpRequest request) {
    final String token = request.uri.queryParameters['token'];

    if (WebSocketTransformer.isUpgradeRequest(request)) {
      return AuthService.userOf(token).then((Model.User user) {
        return WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
          return Notification._register(webSocket, user.ID);
        }).then((_) {
          Model.ClientConnection conn = new Model.ClientConnection.empty()
            ..userID = user.ID
            ..connectionCount = clientRegistry[user.ID].length;
          Event.ClientConnectionState event = new Event.ClientConnectionState(conn);

          _broadcast (event.asMap);
        });
      });
    } else {
      ORhttp.clientError(request, "This interface is meant for webSocket clients.");
      return new Future.error("This interface is meant for webSocket clients.");
    }
  }


  /**
   * Send primitive. Expects the request body to be a JSON string with a list of recipients
   * in the 'recipients' field. The 'message' field is also mandatory for obvious reasons.
   * TODO: Implement delivery status object in the framework.
   */
  static void send(HttpRequest request) {
    ORhttp.extractContent(request).then((String content) {
      List<int> recipients = new List<int>();

      Map json;

      try {
        json = JSON.decode(content);
        (json['recipients'] as List).forEach((int item) => recipients.add(item));
        assert(json.containsKey("message"));
      } catch (exeption) {
        ORhttp.clientError(request, "Malformed JSON body");
        return;
      }

      List delivery_status = new List();
      recipients.forEach((int uid) {
        if (clientRegistry[uid] != null) {
          int count = 0;
          clientRegistry[uid].forEach((WebSocket clientSocket) {
            clientSocket.add(json['message']);
            count++;
          });
          delivery_status.add({
            'uid': uid,
            'sent': count
          });
        } else {
          delivery_status.add({
            'uid': uid,
            'sent': 0
          });
        }
      });

      ORhttp.writeAndClose(request, JSON.encode({
        "status": "ok",
        "delivery_status": delivery_status
      }));
    });
  }

  static void connectionList (HttpRequest request) {
    Iterable<Model.ClientConnection> connections =
      clientRegistry.keys.map((int uid) =>
        new Model.ClientConnection.empty()
          ..userID = uid
          ..connectionCount = clientRegistry[uid].length);

    ORhttp.writeAndClose(request, JSON.encode(connections.toList(growable: false)));
  }

  static void connection (HttpRequest request) {
    int uid  = ORhttp.pathParameter(request.uri, 'connection');
    if (clientRegistry.containsKey(uid)) {
      Model.ClientConnection conn = new Model.ClientConnection.empty()
        ..userID = uid
        ..connectionCount = clientRegistry[uid].length;

      ORhttp.writeAndClose(request, JSON.encode(conn));
    }
    else {
      ORhttp.notFound(request, {'error' : 'No connections for uid $uid'});
    }
  }
}
