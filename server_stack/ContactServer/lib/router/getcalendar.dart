part of contactserver.router;

void getContactCalendar(HttpRequest request) {
  int contactId  = pathParameter(request.uri, 'contact');
  int receptionId = pathParameter(request.uri, 'reception');
  
  db.getReceptionContactCalendarList(receptionId, contactId).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) {
    serverError(request, error.toString());
  });
}
