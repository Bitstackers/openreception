part of receptionserver.router;

void getReceptionCalendar(HttpRequest request) {
  int receptionId = int.parse(request.uri.pathSegments.elementAt(1));
  
  db.getReceptionCalendarList(receptionId).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) {
    serverError(request, error.toString());
  });
}
