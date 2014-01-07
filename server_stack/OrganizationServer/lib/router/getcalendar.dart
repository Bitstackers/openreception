part of router;

void getOrganizationCalendar(HttpRequest request) {
  int orgId = int.parse(request.uri.pathSegments.elementAt(1));
  
  db.getOrganizationCalendarList(orgId).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) {
    serverError(request, error.toString());
  });
}
