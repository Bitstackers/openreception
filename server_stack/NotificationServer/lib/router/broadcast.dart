part of notificationserver.router;

void handleBroadcast (HttpRequest request) {
  
  final String context = '${libraryName}.handleBroadcast';  
  
  extractContent(request).then((String content) {
    
    try {
      JSON.decode(content);
    } catch (exeption){
      clientError (request, "Malformed JSON body");
      return;
    }
    
    int successCount = 0;
    int failCount = 0;
    clientRegistry.forEach((int uid, List<WebSocket> clientSockets) {
      clientSockets.forEach((WebSocket clientSocket) {
        try {
        clientSocket.add(content);
        successCount++;
        }
        catch (error) {
          failCount++;
          logger.errorContext("Failed to send message to client $uid - error: $error", context);
        }
      });
    });
    writeAndClose(request, JSON.encode({"status" : {"success" : successCount, "failed" : failCount}}));
  });
}
