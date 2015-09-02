part of authenticationserver.router;

shelf.Response login(shelf.Request request) {
  final String returnUrlString =
      request.url.queryParameters
          .containsKey('returnurl')
      ? request.url.queryParameters['returnurl']
      : '';

  log.finest('returnUrlString:$returnUrlString');

  try {
    //Because the library does not allow to set custom query parameters
    Map googleParameters = {
      'access_type': 'offline',
      'state': json.config.clientURL
    };

    if (returnUrlString.isNotEmpty) {
      //validating the url by parsing it.
      Uri returnUrl = Uri.parse(returnUrlString);
      googleParameters['state'] = returnUrl.toString();
    }

    Uri authUrl =
        googleAuthUrl(json.config.clientId, json.config.clientSecret, json.config.redirectUri);

    googleParameters.addAll(authUrl.queryParameters);
    Uri googleOauthRequestUrl = new Uri(
        scheme: authUrl.scheme,
        host: authUrl.host,
        port: authUrl.port,
        path: authUrl.path,
        queryParameters: googleParameters,
        fragment: authUrl.fragment);

    log.finest('Redirecting to $googleOauthRequestUrl');

    return new shelf.Response.found(googleOauthRequestUrl);
  } catch (error, stacktrace) {
    log.severe(error, stacktrace);
    return new shelf.Response.internalServerError(
        body: 'Failed log in error:$error');
  }
}
