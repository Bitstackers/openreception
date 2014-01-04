part of router;

void getOrg(HttpRequest request) {

  addCorsHeaders(request.response);
  
  int id = int.parse(request.uri.pathSegments.elementAt(1));
  cache.loadOrganization(id).then((String org) {
    if(org != null) {
      writeAndClose(request, org);

    } else {
      db.getOrganization(id).then((Map value) {
        String org = JSON.encode(value);

        if(value.isEmpty) {
          request.response.statusCode = HttpStatus.NOT_FOUND;
          writeAndClose(request, org);
        } else {
          cache.saveOrganization(id, org)
            .then((_) => writeAndClose(request, org));
        }
      }).catchError((error) => serverError(request, error.toString()));
    }
  });
}

void addCorsHeaders(HttpResponse res) {
  res.headers.add("Access-Control-Allow-Origin", "*, ");
  res.headers.add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
  res.headers.add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}