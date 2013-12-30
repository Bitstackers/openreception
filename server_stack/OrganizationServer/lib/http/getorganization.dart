part of http;

void getOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));
  cache.loadOrganization(id).then((String org) {
    if(org != null) {
      writeAndClose(request, org);

    } else {
      db.getOrganization(id).then((Map value) {
        String org = JSON.encode(value);

        if(value.isEmpty) {
          request.response.statusCode = 404;
          writeAndClose(request, org);
        } else {
          cache.saveOrganization(id, org)
            .then((_) => writeAndClose(request, org));
        }
      }).catchError((error) => serverError(request, error.toString()));
    }
  });
}
