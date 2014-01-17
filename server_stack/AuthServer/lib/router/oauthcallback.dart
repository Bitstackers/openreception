part of organizationserver.router;

void oauthCallback(HttpRequest request) {  
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
      print(json);
      String hash = Sha256Token(json['access_token']);
      savedSession[hash] = json;
      writeAndClose(request, hash);
    }
    
  }).catchError((error) => serverError(request, error.toString()));
}
