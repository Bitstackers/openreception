part of receptionserver.router;

void invalidateReception(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  cache.removeReception(id).then((_) {
    writeAndClose(request, JSON.encode({}));
  }).catchError((error) {
    serverError(request, 'receptionserver.router.invalidateOrg: $error');
  });
}
