part of http;

void invalidateOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(2));

  writeAndClose(request, JSON.encode({}));
}
