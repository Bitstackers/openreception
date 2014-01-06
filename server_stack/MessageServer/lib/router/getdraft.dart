part of router;

void getMessageDrafts(HttpRequest request) {
  addCorsHeaders(request.response);
  
  db.getDraft().then((Map data) {
    writeAndClose(request, JSON.encode(data));
  }).catchError((error) => serverError(request, error.toString()));
}
