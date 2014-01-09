part of messageserver.router;

void getMessageDrafts(HttpRequest request) {
  db.getDraft().then((Map data) {
    writeAndClose(request, JSON.encode(data));
  }).catchError((error) => serverError(request, error.toString()));
}
