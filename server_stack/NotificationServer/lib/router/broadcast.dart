part of notificationserver.router;

void handleBroadcast (HttpRequest request) {
  extractContent(request).then((String content) {
    
    try {
      JSON.decode(content);
    } catch (exeption){
      clientError (request, "Malformed JSON body");
      return;
    }
    
    int count = 0;
    clientRegistry.forEach((int uid, List<WebSocket> clientSockets) {
      clientSockets.forEach((WebSocket clientSocket) {
        clientSocket.add(content);
        count++;
      });
    });
    writeAndClose(request, JSON.encode({"Status" : "done", "client_count" : count}));
  });
}
