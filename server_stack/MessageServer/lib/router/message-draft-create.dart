part of messageserver.router;

/**
 * HTTP response handler for message/create
 */
void messageDraftCreate(HttpRequest request) {
  int userID = 10;

  extractContent(request).then((String content) {
    db.messageDraftCreate(userID, JSON.decode(content)).then((value) {
      writeAndClose(request, JSON.encode(value));
    });
  }).catchError((error) => serverError(request, error.runtimeType +  error.toString()));
}

