part of authenticationserver.router;

void invalidateToken(HttpRequest request) {
  String token = request.uri.pathSegments.elementAt(1);

  if(token != null && token.isNotEmpty) {
    try {
      vault.removeToken(token);
      writeAndClose(request, '{}');
    } catch(error) {
      serverError(request, 'authenticationserver.router.invalidateToken: Failed to remove token "$token" $error');
    }
  } else {
    serverError(request, 'authenticationserver.router.invalidateToken: No token parameter was specified');
  }

}