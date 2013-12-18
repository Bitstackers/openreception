part of http;

void updateOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));
  extractContent(request).then((String content) {
    Map data = JSON.decode(content);
    String full_name = data['full_name'];
    String uri = data['uri'];
    Map attributes = data['attributes'];
    bool enabled = data['enabled'];

    db.updateOrganization(id, full_name, uri, attributes, enabled).then((Map value) {
      writeAndClose(request, JSON.encode(value));
    });
  });
}
