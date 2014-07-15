part of messageserver.router;

void messageDraftSingle(HttpRequest request) {
  int messageID  = pathParameter(request.uri, 'draft');
  
    db.messageDraftSingle(messageID).then((Map value) {
      writeAndClose(request, JSON.encode(value));
    }).catchError((Error error, StackTrace stackTrace) => _onException(request, error, stackTrace));
}

void _onException (HttpRequest request, Error error, StackTrace stackTrace) {
  
  if (error is db.NotFound) {
    notFound (request, {'description' :'not found'});
  } else {
    serverErrorTrace(request, error, stackTrace: stackTrace);  
  }
}