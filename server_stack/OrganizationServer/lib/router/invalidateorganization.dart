part of organizationserver.router;

void invalidateOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  cache.removeOrganization(id).then((_) {
    writeAndClose(request, JSON.encode({}));
  }).catchError((error) {
    serverError(request, 'organizationserver.router.invalidateOrg: $error');
  });
}
