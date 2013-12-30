part of router;

void getOrgList(HttpRequest request) {
  db.getOrganizationList().then((Map value) {
    writeAndClose(request, JSON.encode(value));
  });
}
