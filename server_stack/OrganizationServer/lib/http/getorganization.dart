part of http;

void getOrgSlow(HttpRequest request) {
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

void getOrg(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));
  String path = '${config.cache}org/$id.json';

  File file = new File(path);
  file.openRead()
    .handleError((error) {log('Cache miss: $path. $error');})
    .pipe(request.response)
    .catchError((_) {
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
  });
}
