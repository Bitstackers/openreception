part of http;

void deleteOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  db.deleteOrganization(id).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  });
}
