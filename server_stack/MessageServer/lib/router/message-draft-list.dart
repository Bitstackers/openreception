part of messageserver.router;

void messageDraftList(HttpRequest request) {
  db.messageDraftList(0, 100).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request, error.toString()));
}

