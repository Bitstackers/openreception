part of messageserver.router;

/**
 * HTTP Request handler for returning a single message resource.
 */
void messageSingle(HttpRequest request) {
  int messageID  = pathParameter(request.uri, 'message');
  
  db.messageSingle(messageID).then((Map retrievedMessage) {
    print (retrievedMessage);
    writeAndClose(request, JSON.encode(retrievedMessage));
  });
}
