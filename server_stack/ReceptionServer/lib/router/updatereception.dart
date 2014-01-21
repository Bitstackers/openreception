part of receptionserver.router;

void updateReception(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  extractContent(request).then((String content) {
    Map data = JSON.decode(content);
    String full_name = data['full_name'];
    String uri = data['uri'];
    Map attributes = data['attributes'];
    bool enabled = data['enabled'];

    db.updateReception(id, full_name, uri, attributes, enabled).then((Map value) {
      cache.removeReception(id).whenComplete(() {
        writeAndClose(request, JSON.encode(value));
      });
    });
  });
}
