part of http;

void deleteOrg(HttpRequest request) {
  int orgId = int.parse(request.uri.pathSegments.elementAt(1));
  int contactId = int.parse(request.uri.pathSegments.elementAt(3));

  db.deleteOrganization(orgId, contactId).then((Map value) {
    cache.removeContact(orgId, contactId).whenComplete(() {
      writeAndClose(request, JSON.encode(value));
    });
  });
}
