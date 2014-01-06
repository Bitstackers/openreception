part of router;

void invalidateOrg(HttpRequest request) {
  addCorsHeaders(request.response);
  
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  cache.removeOrganization(id).whenComplete(() {
    writeAndClose(request, JSON.encode({}));
  });
}
