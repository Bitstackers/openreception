part of organizationserver.router;

void deleteOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  db.deleteOrganization(id).then((Map value) {
    return cache.removeOrganization(id).whenComplete(() {
      writeAndClose(request, JSON.encode(value));
    });
  }).catchError((error) {
    serverError(request, 'organizationserver.router.deleteOrg: $error');
  });
}
