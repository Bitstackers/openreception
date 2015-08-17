part of authenticationserver.router;

Future<shelf.Response> refresher(shelf.Request request) {
  final String token = shelf_route.getPathParameters(request).containsKey(
      'token') ? shelf_route.getPathParameter(request, 'token') : '';

  try {
    Map content = vault.getToken(token);

    String refreshToken = content['refresh_token'];

    Uri url = Uri.parse('https://www.googleapis.com/oauth2/v3/token');
    Map body = {
      'refresh_token': refreshToken,
      'client_id': config.clientId,
      'client_secret': config.clientSecret,
      'grant_type': 'refresh_token'
    };

    return httpClient.post(url, JSON.encode(body)).then(
        (String response) => new shelf.Response.ok(
            'BODY \n ==== \n${JSON.encode(body)} \n\n RESPONSE '
            '\n ======== \n ${response}'));
  } catch (error, stackTrace) {
    log.severe(error, stackTrace);

    return new Future.value(
        new shelf.Response.internalServerError(body: '$error'));
  }
}
