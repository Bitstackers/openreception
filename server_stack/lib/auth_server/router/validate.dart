part of authenticationserver.router;

shelf.Response validateToken(shelf.Request request) {
  final String token = shelf_route.getPathParameters(request).containsKey(
      'token') ? shelf_route.getPathParameter(request, 'token') : '';

  if (token.isNotEmpty) {
    if(token == Configuration.authServer.serverToken) {
      return new shelf.Response.ok(JSON.encode(const {}));
    }

    if (vault.containsToken(token)) {
      try {
        watcher.seen(token);
      } catch (error, stacktrace) {
        log.severe(error, stacktrace);
      }

      return new shelf.Response.ok(JSON.encode(const {}));
    } else {
      return new shelf.Response.notFound(JSON.encode(const {}));
    }
  }

  return new shelf.Response(400, body: 'Invalid or missing token passed.');
}
