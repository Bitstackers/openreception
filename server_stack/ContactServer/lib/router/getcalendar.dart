part of contactserver.router;

void getContactCalendar(HttpRequest request) {
  int contactId  = pathParameter(request.uri, 'contact');
  int receptionId = pathParameter(request.uri, 'reception');
  existsContact(contactId, receptionId).then((bool exists) {
    if(exists) {
      return db.getReceptionContactCalendarList(receptionId, contactId).then((Map value) {
        writeAndClose(request, JSON.encode(value));
      });
    } else {
      request.response.statusCode = HttpStatus.NOT_FOUND;
      writeAndClose(request, JSON.encode({}));
    }
  }).catchError((error) {
    serverError(request, error.toString());
  });
  
}
