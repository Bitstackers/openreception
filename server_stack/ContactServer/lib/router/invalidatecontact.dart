part of router;

void invalidateOrg(HttpRequest request) {
  addCorsHeaders(request.response);
  
  int orgId = int.parse(request.uri.pathSegments.elementAt(1));
  int contactId = int.parse(request.uri.pathSegments.elementAt(3));

  cache.removeContact(orgId, contactId).whenComplete(() {
    writeAndClose(request, JSON.encode({}));
  });
}
