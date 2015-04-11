part of authenticationserver.router;

void oauthCallback(HttpRequest request) {
  try {
    //State is used as a return URL.
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

    //Now we have the "code" which will be exchanged to a token.
    http.post(tokenEndpoint, headers: {'content-type':'application/x-www-form-urlencoded'}, body: postBody)
      .then((http.Response response) {
      Map json = JSON.decode(response.body);

      if(json.containsKey('error')) {
        serverError(request, 'authenticationserver.router.oauthCallback() Authtication failed. "${json}"');

      } else {
        json['expiresAt'] = dateTimeToJson(new DateTime.now().add(config.tokenexpiretime));
        return getUserInfo(json['access_token']).then((Map userData) {
          if(userData == null || userData.isEmpty) {
            logger.debug('authenticationserver.router.oauthCallback() token:"${json['access_token']}" userdata:"${userData}"');
            request.response.statusCode = 403;
            writeAndClose(request, JSON.encode({'status': 'Forbidden!'}));

          } else {
            json['identity'] = userData;

            String cacheObject = JSON.encode(json);
            String hash = Sha256Token(cacheObject);

            try {
              vault.insertToken(hash, json);
              Map queryParameters = {'settoken' : hash};
              request.response.redirect(new Uri(
                  scheme: returnUrl.scheme,
                  userInfo: returnUrl.userInfo,
                  host: returnUrl.host,
                  port: returnUrl.port,
                  path: returnUrl.path,
                  queryParameters: queryParameters));

            } catch(error) {
              serverError(request, 'authenticationserver.router.oauthCallback uri ${request.uri} error: "${error}" data: "$json"');
            }
          }
        }).catchError((error) {
          logger.error('authenticationserver.router.oauthCallback() requested userInfo error "${error}"');
          request.response.statusCode = 403;
          writeAndClose(request, JSON.encode({'status': 'Forbidden.'}));
        });
      }

    }).catchError((error) => serverError(request, 'authenticationserver.router.oauthCallback uri ${request.uri} error: "${error}"'));
  } catch(e) {
    serverError(request, 'authenticationserver.router.oauthCallback() error "${e}" Url "${request.uri}"');
  }
}

/**
 * Asks google for the user data, for the user bound to the [access_token].
 */
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
