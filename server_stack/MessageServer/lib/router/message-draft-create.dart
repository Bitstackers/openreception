part of messageserver.router;

void messageDraftCreate(HttpRequest request) {
  int userID = 10;

  extractContent(request).then((String content) {
    Map data = JSON.decode(content);
    db.messageDraftCreate(userID, content).then((value) {
      writeAndClose(request, JSON.encode(value));
    });
  }).catchError((error) => serverError(request, error.runtimeType +  error.toString()));
}

