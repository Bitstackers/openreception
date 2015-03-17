part of cdrserver.router;

void insertCdrData(HttpRequest request) {
  //AUTH
  //Check if the shared Secret is matching, and the whitelisted IPs.

  extractContent(request).then((String content) {
    Map json;
    try {
      json = JSON.decode(content);
    } catch(error) {
      clientError(request, 'Malformed json');
      return new Future.value();
    }

    CdrEntry entry;
    try {
      entry = new CdrEntry.fromJson(json);
    } catch(error) {
      clientError(request, 'Missing document field. ${error}');
      return new Future.value();
    }

    return db.newcdrEntry(entry).then((_) {
      allOk(request);
    });
  }).catchError((error, stack) {
    serverError(request, 'Error: "${error}", stack: \n"${stack}"');
  });
}
