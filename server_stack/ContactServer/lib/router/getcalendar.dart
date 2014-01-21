part of contactserver.router;

void getContactCalendar(HttpRequest request) {
  int receptionId = int.parse(request.uri.pathSegments.elementAt(1));
  int contactId = int.parse(request.uri.pathSegments.elementAt(3));
  
  db.getReceptionContactCalendarList(receptionId, contactId).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) {
    serverError(request, error.toString());
  });
}
