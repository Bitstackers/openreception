part of router;

void deleteOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  db.deleteOrganization(id).then((Map value) {
    cache.removeOrganization(id).whenComplete(() {
      writeAndClose(request, JSON.encode(value));
    });
  });
}
