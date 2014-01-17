part of organizationserver.router;

void userinfo(HttpRequest request) {
  if(request.uri.queryParameters.containsKey('token')) {
    String token = request.uri.queryParameters['token'];
    if(savedSession.containsKey(token)) {
      Map json = savedSession[token];
      String url = 'https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=${json['access_token']}';
      http.get(url).then((http.Response response) {
        Map googleProfile = JSON.decode(response.body);
        db.getUser(googleProfile['email']).then((Map agent) {
          agent['remote_attributes'] = googleProfile;
          writeAndClose(request, JSON.encode(agent));
        }).catchError((error) => serverError(request, error.toString()));
      }).catchError((error) => serverError(request, error.toString()));
    } else {
      //Unknown token
    }
  } else {
    //Missing token
    
  }
  
  try {
    Map json = savedSession[request.uri.queryParameters['token']];
    String url = 'https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=${json['access_token']}';
    http.get(url).then((http.Response response) {
      Map googleProfile = JSON.decode(response.body);
      db.getUser(googleProfile['email']).then((Map agent) {
        agent['remote_attributes'] = googleProfile;
        writeAndClose(request, JSON.encode(agent));
      }).catchError((error) => serverError(request, error.toString()));
    }).catchError((error) => serverError(request, error.toString()));
  } catch(_) {
    //TODO not Authenticated
    serverError(request, 'Token was not supplied');
  }
  
}
