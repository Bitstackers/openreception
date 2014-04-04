part of messageserver.router;

void messageDraftSingle(HttpRequest request) {
  int messageID  = pathParameter(request.uri, 'draft');
  
  
    db.messageDraftSingle(messageID).then((Map value) {
      writeAndClose(request, JSON.encode(value));
    }).catchError((Error error) => _onException(error, request));
}

void _onException (Error error, HttpRequest request) {
  
  if (error.runtimeType == db.NotFound) {
    resourceNotFound (request);
  } else {
    serverError(request, error.runtimeType.toString() + "Oh noes: " +  error.toString());  
  }
}