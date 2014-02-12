part of authenticationserver.router;

void userinfo(HttpRequest request) { 
  String token = request.uri.pathSegments.elementAt(1);
  
  cache.loadToken(token).then((String content) {
    watcher.seen(token).catchError((error) {
      log('authenticationserver.router.userinfo() watcher threw ${error}');
    });
    
    Map json = JSON.decode(content);
    if(json.containsKey('identity')) {
      String result = JSON.encode(json['identity']);
      writeAndClose(request, result);
    } else {
      request.response.statusCode = 404;
      writeAndClose(request, JSON.encode({'Status': 'Not found'}));
      log("authenticationserver.router.userinfo() save object didn't have user data.");
    }
  }).catchError((error) {
    request.response.statusCode = 404;
    writeAndClose(request, JSON.encode({'Status': 'Not found'}));
    log('authenticationserver.router.userinfo() Tried to load token ${error}');
    //serverError(request, 'authenticationserver.router.userinfo: $error');
  });  
}
