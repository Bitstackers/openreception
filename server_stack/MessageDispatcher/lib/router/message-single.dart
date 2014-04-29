part of messageserver.router;

void messageSingle(HttpRequest request) {
  int messageID  = pathParameter(request.uri, 'message');
  
  db.messageSingle(messageID).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request, error.toString()));
}
