part of router;

void getOrgList(HttpRequest request) {
  addCorsHeaders(request.response);

  db.getOrganizationList().then((Map value) {
    writeAndClose(request, JSON.encode(value));
  });
}
