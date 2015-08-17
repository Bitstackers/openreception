part of authenticationserver.router;

shelf.Response validateToken(shelf.Request request) {
  final String token = shelf_route.getPathParameters(request).containsKey(
      'token') ? shelf_route.getPathParameter(request, 'token') : '';

  if (token.isNotEmpty) {
    bool exists = vault.containsToken(token);
    if (exists) {
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
