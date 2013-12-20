part of http;

void getMessageList(HttpRequest request) {
  db.getMessageList().then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request, error));
}
