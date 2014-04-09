part of notificationserver.router;

/**
 * WebSocket handling. Registers and un-registers the the websocket in the global registry.
 */
void handleWebsocket (WebSocket webSocket, int uid) {
  logger.debugContext('New WebSocket connection from uid $uid', "handleWebsocket");
  
  if (clientRegistry[uid] == null) {
    clientRegistry[uid] = new List<WebSocket>();
  }
  clientRegistry[uid].add(webSocket);
 
  // Listen for incoming data. We expect the data to be a JSON-encoded String.
  webSocket
    .map((string) => JSON.decode(string))
    .listen((json) {
        //TODO Log
        webSocket.add(json); // Echo.
      
    }, onError : (error) {
      //TODO Log
    }, onDone : () {
      logger.debugContext('Disconnected WebSocket connection from uid $uid', "handleWebsocket");
      clientRegistry[uid].remove(webSocket);
    }
    );
}

/**
 * Upgrades an incoming HTTP request to a webSocket and attaches the appropriate event handlers.
 */

void registerWebsocket (HttpRequest request) {
  if (WebSocketTransformer.isUpgradeRequest(request)) {
    getUserID(request, config.authUrl).then((int uid) {
      WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
        handleWebsocket(webSocket, uid);      
      });
    });
    
  } else {
    clientError(request, "This interface is meant for webSocket clients.");
    return;
  }
}
