part of http;

void getOrgList(HttpRequest request) {
  int orgId = int.parse(request.uri.pathSegments.elementAt(1));

  db.getOrganizationList(orgId).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request, error.toString()));
}
