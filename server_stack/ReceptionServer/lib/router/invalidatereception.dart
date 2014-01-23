part of receptionserver.router;

void invalidateReception(HttpRequest request) {
  int id = pathParameter(request.uri, 'reception');

  cache.removeReception(id).then((_) {
    writeAndClose(request, JSON.encode({}));
  }).catchError((error) {
    serverError(request, 'receptionserver.router.invalidateOrg: $error');
  });
}
