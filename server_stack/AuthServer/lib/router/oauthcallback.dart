part of authenticationserver.router;

void oauthCallback(HttpRequest request) {
  try {
    String state = queryParameter(request.uri, 'state');
    if(state == null) {
      serverError(request, 'authenticationserver.router.oauthCallback() State parameter is missing "${request.uri}"');
      return;
    }
    Uri returnUrl = Uri.parse(state);
    Map postBody = 
      {
        "grant_type": "authorization_code",
        "code": request.uri.queryParameters['code'],
        "redirect_uri": config.redirectUri.toString(),
        "client_id": config.clientId,
        "client_secret": config.clientSecret
      };
    String body = mapToUrlFormEncodedPostBody(postBody);
    logger.debug('authenticationserver.router.oauthCallback() Sending request to google. "${tokenEndpoint}" body "${body}"');
    
    http.post(tokenEndpoint, headers: {'content-type':'application/x-www-form-urlencoded'}, body: body).then((http.Response response) {
      Map json = JSON.decode(response.body);
      
      if(json.containsKey('error')) {
        serverError(request, 'Authtication failed. ${json}');
        
      } else {
        //TODO How long should a token be valid for? configuration?
        json['expiresAt'] = dateTimeToJson(new DateTime.now().add(new Duration(hours: 1)));
        return getUserInfo(json['access_token']).then((Map userData) {
          if(userData == null || userData.isEmpty) {
            request.response.statusCode = 403;
            writeAndClose(request, JSON.encode({'status': 'Forbidden!'}));
            
          } else {
            json['identity'] = userData;
  
            String cacheObject = JSON.encode(json);
            String hash = Sha256Token(cacheObject);
            
            return cache.saveToken(hash, cacheObject).then((_) {
              Map queryParameters = {'settoken' : hash};
              request.response.redirect(new Uri(scheme: returnUrl.scheme, userInfo: returnUrl.userInfo, host: returnUrl.host, port: returnUrl.port, path: returnUrl.path, queryParameters: queryParameters));
            }).catchError((error) {
              serverError(request, error.toString());
            });
          }
        }).catchError((error) {
          log(error);
          request.response.statusCode = 403;
          writeAndClose(request, JSON.encode({'status': 'Forbidden.'}));
        });
      }
      
    }).catchError((error) => serverError(request, error.toString()));
  } catch(e) {
    serverError(request, 'authenticationserver.router.oauthCallback() error "${e}" Url "${request.uri}"');
  }
}


Future<Map> getUserInfo(String access_token) {
  String url = 'https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=${access_token}';
  
  return http.get(url).then((http.Response response) {
    Map googleProfile = JSON.decode(response.body);
    return db.getUser(googleProfile['email']).then((Map agent) {
      if(agent.isNotEmpty) {
        agent['remote_attributes'] = googleProfile;
        return agent;
      } else {
        return null;
      }
    });
  });
}
