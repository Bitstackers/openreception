part of authenticationserver.router;

void refresher(HttpRequest request) {
  String token = request.uri.pathSegments.elementAt(1);

  try {
    Map content = vault.getToken(token);

    String refreshToken = content['refresh_token'];

    Uri url = Uri.parse('https://www.googleapis.com/oauth2/v3/token');
    Map body = {'refresh_token': refreshToken,
                'client_id': config.clientId,
                'client_secret': config.clientSecret,
                'grant_type': 'refresh_token'};
    http.post(url, body: body).then((http.Response response) {
      writeAndClose(request, 'BODY \n ==== \n${JSON.encode(body)} \n\n RESPONSE \n ======== \n ${response.body}');
    });

  } catch(error) {
    request.response.statusCode = 500;
    writeAndClose(request, JSON.encode({'Status': 'Error'}));
    log('authenticationserver.router.refresher() Tried to load token URL ${request.uri} Error: ${error}');
  }
}
