part of http;

void getOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  db.getOrganization(id).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  });
}
