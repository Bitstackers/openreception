part of router;

void getMessageList(HttpRequest request) {
  addCorsHeaders(request.response);
  
  db.getMessageList().then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request, error));
}
