part of authenticationserver.router;

void login(HttpRequest request) {
  try {
    //Because the library does not allow to set custom query parameters
    Map googleParameters = {
      'access_type': 'offline',
      'state': config.clientURL
    };

    if(request.uri.queryParameters.containsKey('returnurl')) {
      //validating the url by parsing it.
      Uri returnUrl = Uri.parse(request.uri.queryParameters['returnurl']);
      googleParameters['state'] = returnUrl.toString();
    }

    Uri authUrl = googleAuthUrl(config.clientId, config.clientSecret, config.redirectUri);

    googleParameters.addAll(authUrl.queryParameters);
    Uri googleOauthRequestUrl = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: authUrl.path, queryParameters: googleParameters, fragment: authUrl.fragment);
    request.response.redirect(googleOauthRequestUrl);

  } catch(error) {
    serverError(request, 'authenticationserver.router.login: $error');
  }
}
