part of authenticationserver.router;

void invalidateToken(HttpRequest request) {
  String token = request.uri.pathSegments.elementAt(1);
  
  if(token != null && token.isNotEmpty) {
    cache.removeToken(token).then((_) {
      writeAndClose(request, '{}');
    }).catchError((error) {
      serverError(request, 'authenticationserver.router.invalidateToken: Failed to remove token "$token" $error');
    });
  } else {
    serverError(request, 'authenticationserver.router.invalidateToken: No token parameter was specified');
  }
  
}