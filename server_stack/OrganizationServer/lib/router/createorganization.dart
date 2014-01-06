part of router;

void createOrg(HttpRequest request) {
  addCorsHeaders(request.response);
  
  extractContent(request).then((String content) {
    Map data = JSON.decode(content);
    String full_name = data['full_name'];
    String uri = data['uri'];
    Map attributes = data['attributes'];
    bool enabled = data['enabled'];

    db.createOrganization(full_name, uri, attributes, enabled).then((Map value) {
      writeAndClose(request, JSON.encode(value));
    }).catchError((error) => serverError(request, error.toString()));
  }).catchError((error) => serverError(request, error.toString()));
}
