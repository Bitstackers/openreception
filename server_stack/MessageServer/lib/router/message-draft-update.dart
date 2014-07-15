part of messageserver.router;

void messageDraftUpdate(HttpRequest request) {
  int draftID  = pathParameter(request.uri, 'draft');
  
  extractContent(request).then((String content) {
    Map data = JSON.decode(content);
    db.messageDraftUpdate(draftID, content).then((value) {
      writeAndClose(request, JSON.encode(value));
    });
  }).catchError((error, stackTrace) => _onException(request, error, stackTrace));
}
