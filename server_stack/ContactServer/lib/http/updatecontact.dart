part of http;

void updateOrg(HttpRequest request) {
  int orgId = int.parse(request.uri.pathSegments.elementAt(1));
  int contactId = int.parse(request.uri.pathSegments.elementAt(3));

  extractContent(request).then((String content) {
    Map data = JSON.decode(content);
    String full_name = data['full_name'];
    String uri = data['uri'];
    Map attributes = data['attributes'];
    bool enabled = data['enabled'];

    db.updateOrganization(orgId, contactId, full_name, uri, attributes, enabled).then((Map value) {
      cache.removeContact(orgId, contactId).whenComplete(() {
        writeAndClose(request, JSON.encode(value));
      });
    });
  });
}
