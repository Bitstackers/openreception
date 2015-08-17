part of authenticationserver.router;

shelf.Response userinfo(shelf.Request request) {
  final String token = shelf_route.getPathParameters(request).containsKey(
      'token') ? shelf_route.getPathParameter(request, 'token') : '';

  try {
    Map content = vault.getToken(token);
    try {
      watcher.seen(token);
    } catch (error, stacktrace) {
      log.severe(error, stacktrace);
    }

    if (!content.containsKey('identity')) {
      return new shelf.Response.internalServerError(
          body: 'Parse error in stored map');
    }

    return new shelf.Response.ok(JSON.encode(content['identity']));
  } catch (error, stacktrace) {
    log.severe(error, stacktrace);

    return new shelf.Response.notFound(JSON.encode({'Status': 'Not found'}));
  }
}
