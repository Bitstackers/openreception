part of router;

void getOrgList(HttpRequest request) {
  db.getOrganizationList().then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request,'db.getOrganizationListReturn failed: $error'));
}
