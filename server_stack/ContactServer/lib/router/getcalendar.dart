part of router;

void getContactCalendar(HttpRequest request) {
  addCorsHeaders(request.response);
  int orgId = int.parse(request.uri.pathSegments.elementAt(1));
  int contactId = int.parse(request.uri.pathSegments.elementAt(3));
  
  db.getOrganizationContactCalendarList(orgId, contactId).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) {
    serverError(request, error.toString());
  });
}
