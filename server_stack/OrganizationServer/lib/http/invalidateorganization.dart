part of http;

void invalidateOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  cache.removeOrganization(id).whenComplete(() {
    writeAndClose(request, JSON.encode({}));
  });
}
