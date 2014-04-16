part of messageserver.router;

void messageResend(HttpRequest request) {
  
  final String context = packageName + ".messageResend";
  
  int messageID  = pathParameter(request.uri, 'draft');
  
    db.messageDraftSingle(messageID).then((Map value) {
      writeAndClose(request, JSON.encode(value));
    }).catchError((Error error) => _onException(error, request));
}
