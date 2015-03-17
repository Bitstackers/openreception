part of authenticationserver.router;

void validateToken(HttpRequest request) {
  String token = request.uri.pathSegments.elementAt(1);

  if(token != null && token.isNotEmpty) {
    bool exists = vault.containsToken(token);
    if (exists) {
      try {
        watcher.seen(token);
      } catch(error) {
        log('authenticationserver.router.validateToken() watcher threw "${error}" for token "${token}" on uri "${request.uri}"');
      }

      request.response.statusCode = 200;
      writeAndClose(request, '{}');
    } else {
      request.response.statusCode = 404;
      writeAndClose(request, '{}');
    }
  }
}
