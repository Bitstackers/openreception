part of notificationserver.router;

abstract class Notification {

  static const String className = '$libraryName.Notification';
  static final Logger log       = new Logger(Notification.className);

  /**
   * Broadcasts a message to every connected websocket.
   */
  static void broadcast(HttpRequest request) {

    ORhttp.extractContent(request).then((String content) {
      try {
        JSON.decode(content);
      } catch (exeption) {
        ORhttp.clientError(request, "Malformed JSON body");
        return;
      }

      int successCount = 0;
      int failCount = 0;
      clientRegistry.forEach((int uid, List<WebSocket> clientSockets) {
        clientSockets.forEach((WebSocket clientSocket) {
          try {
            clientSocket.add(content);
            successCount++;
          } catch (error) {
            failCount++;
            log.finest("Failed to send message to client $uid - error: $error");
          }
        });
      });
      ORhttp.writeAndClose(request, JSON.encode({
        "status": {
          "success": successCount,
          "failed": failCount
        }
      }));
    });
  }

  /**
   * WebSocket registration handling.
   * Registers and un-registers the the websocket in the global registry.
   */
  static void _register(WebSocket webSocket, int uid) {
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
    });
  }

  /**
   * Upgrades an incoming HTTP request to a webSocket and attaches the appropriate event handlers.
   */
  static void connect(HttpRequest request) {
    final String token = request.uri.queryParameters['token'];

    if (WebSocketTransformer.isUpgradeRequest(request)) {
      AuthService.userOf(token).then((Model.User user) {
        WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
          Notification._register(webSocket, user.ID);
        });
      });
    } else {
      ORhttp.clientError(request, "This interface is meant for webSocket clients.");
      return;
    }
  }


  /**
   * Send primitive. Expects the request body to be a JSON string with a list of recipients
   * in the 'recipients' field. The 'message' field is also mandatory for obvious reasons.
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
            print("Sending to user $uid");
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

  /**
   * Status for every connected websocket.
   */
  static Future status(HttpRequest request) {
    List<Map> clients = [];
      clientRegistry.forEach((int uid, List<WebSocket> clientSockets) {
        Map client = {'uid' : uid, 'socketCount' : clientSockets.length};
        clients.add(client);
      });
      ORhttp.writeAndClose(request, JSON.encode(clients));
  }
}
