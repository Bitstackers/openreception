part of messageserver.router;

void messageList(HttpRequest request) {
  db.messageList().then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request, error.toString()));
}
