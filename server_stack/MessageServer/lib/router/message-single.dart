part of messageserver.router;

/**
 * HTTP Request handler for returning a single message resource.
 */
void messageSingle(HttpRequest request) {
  int messageID  = pathParameter(request.uri, 'message');
  
  (new Message.stub(messageID)).loadFromDatabase().then((Message retrievedMessage) {
    writeAndClose(request, JSON.encode(retrievedMessage.toMap));
  });
}
