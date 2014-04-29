part of messagedispatcher.router;

void messageDraftSingle(HttpRequest request) {
  int messageID  = pathParameter(request.uri, 'draft');
  
  resourceNotFound (request);
}

void _onException (Error error, HttpRequest request) {
  
  if (error.runtimeType == db.NotFound) {
    resourceNotFound (request);
  } else {
    serverError(request, error.runtimeType.toString() + "Oh noes: " +  error.toString());  
  }
}

/**
 * TODO: Reimplement this.
 */
void messageDispatchAll(HttpRequest request) {
  
  final String context = ".messageDispatchAll"; 
  
  db.messageQueueList().then((List currentQueue) {
    logger.debugContext("Trying to dispatch ${currentQueue.length.toString()} queued messages.", context);
    
    
    serverError(request, JSON.encode({"error" : "not implemented"}));
  }).catchError((Error error) => _onException(error, request));
}
