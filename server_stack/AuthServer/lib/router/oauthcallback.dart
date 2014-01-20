part of authenticationserver.router;

void oauthCallback(HttpRequest request) {
  Uri returnUrl = Uri.parse(queryParameter(request.uri, 'state'));
  Map postBody = 
    {
      "grant_type": "authorization_code",
      "code": request.uri.queryParameters['code'],
      "redirect_uri": config.redirectUri.toString(),
      "client_id": config.clientId,
      "client_secret": config.clientSecret
    };
  
  String body = mapToUrlFormEncodedPostBody(postBody);
  http.post(tokenEndpoint, headers: {'content-type':'application/x-www-form-urlencoded'}, body: body).then((http.Response response) {
    Map json = JSON.decode(response.body);
    
    if(json.containsKey('error')) {
      serverError(request, 'Authtication failed. ${json['error']}');
    } else {
      String hash = Sha256Token(json['access_token']);
      return cache.saveToken(hash, response.body).then((_) {
        Map queryParameters = {'settoken' : hash};
        request.response.redirect(new Uri(scheme: returnUrl.scheme, userInfo: returnUrl.userInfo, host: returnUrl.host, port: returnUrl.port, path: returnUrl.path, queryParameters: queryParameters));
      }).catchError((error) {
        serverError(request, error.toString());
      });
    }
    
  }).catchError((error) => serverError(request, error.toString()));
}
