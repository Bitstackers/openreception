part of authenticationserver.router;

void userinfo(HttpRequest request) {
  String token = request.uri.pathSegments.elementAt(1);

  try {
    Map content = vault.getToken(token);
    try {
      watcher.seen(token);
    } catch(error) {
      log('authenticationserver.router.userinfo() watcher threw "${error}" Url "${request.uri}"');
    }

    if(content.containsKey('identity')) {
      String result = JSON.encode(content['identity']);
      writeAndClose(request, result);
    } else {
      request.response.statusCode = 404;
      writeAndClose(request, JSON.encode({'Status': 'Not found'}));
      log('authenticationserver.router.userinfo() save object did not have user data. "${content}" Url "${request.uri}"');
    }
  } catch(error) {
    request.response.statusCode = 404;
    writeAndClose(request, JSON.encode({'Status': 'Not found'}));
    log('authenticationserver.router.userinfo() Tried to load token URL ${request.uri} Error: ${error}');
  }
}
