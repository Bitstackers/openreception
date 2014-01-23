part of receptionserver.router;

void getReceptionCalendar(HttpRequest request) {
  int receptionId = pathParameter(request.uri, 'reception');
  
  db.getReceptionCalendarList(receptionId).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) {
    serverError(request, error.toString());
  });
}
