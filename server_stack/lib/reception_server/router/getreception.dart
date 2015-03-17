part of receptionserver.router;

void getReception(HttpRequest request) {
  int id = pathParameter(request.uri, 'reception');
  
  cache.loadReception(id).then((String reception) {
      writeAndClose(request, reception);
  }).catchError((error) { 
    return db.getReception(id).then((Map value) {
      String org = JSON.encode(value);

      if(value.isEmpty) {
        request.response.statusCode = HttpStatus.NOT_FOUND;
        writeAndClose(request, org);
      } else {
        return cache.saveReception(id, org)
            .then((_) => writeAndClose(request, org));
        }
      }).catchError((error) => serverError(request, 'receptionserver.router.getReception: $error'));
  });
}
