part of authenticationserver.router;

void invalidateToken(HttpRequest request) {
  String token = queryParameter(request.uri, 'token');
  
  if(token != null && token.isNotEmpty) {
    cache.removeToken(token).then((_) {
      writeAndClose(request, '{}');
    }).catchError((_) {
      serverError(request, 'authenticationserver.router.invalidateToken: Failed to remove token $token');
    });
  } else {
    serverError(request, 'authenticationserver.router.invalidateToken: No token parameter was specified');
  }
  
}