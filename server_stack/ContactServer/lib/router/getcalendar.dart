part of contactserver.router;

void getContactCalendar(HttpRequest request) {
  int contactID   = pathParameter(request.uri, 'contact');
  int receptionID = pathParameter(request.uri, 'reception');

  Contact.exists (contactID : contactID, receptionID : receptionID).then((bool exists) {
    if(exists) {
      return db.getReceptionContactCalendarList(receptionID, contactID).then((List<Map> value) {
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
