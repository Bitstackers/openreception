part of receptionserver.router;

void getReceptionList(HttpRequest request) {
  db.getReceptionList().then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request,'db.getreceptionListReturn failed: $error'));
}
