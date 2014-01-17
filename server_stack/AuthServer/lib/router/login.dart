part of authenticationserver.router;

void login(HttpRequest request) {
  Uri bobUrl = Uri.parse('localhost:3030/Bob/web/bob.dart');
  
  //Because the library does not allow to set custom query parameters
  Map googleParameters = {
    'access_type': 'offline'
  };
  Uri authUrl = googleAuthUrl(config.clientId, config.clientSecret, config.redirectUri);
  
  googleParameters.addAll(authUrl.queryParameters);
  Uri googleOauthRequestUrl = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: authUrl.path, queryParameters: googleParameters, fragment: authUrl.fragment);  
  request.response.redirect(googleOauthRequestUrl);
}
