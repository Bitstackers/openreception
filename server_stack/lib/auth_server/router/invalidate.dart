part of authenticationserver.router;

shelf.Response invalidateToken(shelf.Request request) {
  final String token = shelf_route.getPathParameter(request, 'token');

  if (token != null && token.isNotEmpty) {
    try {
      vault.removeToken(token);
      return new shelf.Response.ok(JSON.encode(const {}));
    } catch (error, stacktrace) {
      log.severe(error, stacktrace);
      return new shelf.Response.internalServerError(
          body: 'authenticationserver.router.invalidateToken: '
          'Failed to remove token "$token" $error');
    }
  } else {
    return new shelf.Response.internalServerError(
        body: 'authenticationserver.router.invalidateToken: '
        'No token parameter was specified');
  }
}
