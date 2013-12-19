part of http;

void getContact(HttpRequest request) {
  int orgId = int.parse(request.uri.pathSegments.elementAt(1));
  int contactId = int.parse(request.uri.pathSegments.elementAt(3));
  cache.loadContact(orgId, contactId).then((String org) {
    if(org != null) {
      writeAndClose(request, org);

    } else {
      db.getContact(orgId, contactId).then((Map value) {
        String contact = JSON.encode(value);

        if(value.isEmpty) {
          writeAndClose(request, contact);
        } else {
          cache.saveContact(orgId, contactId, contact)
            .then((_) => writeAndClose(request, contact));
        }
      }).catchError((error) => serverError(request, error.toString()));
    }
  });
}
