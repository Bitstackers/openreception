/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.authentication_server.router;

Future<shelf.Response> oauthCallback(shelf.Request request) {
  final String stateString = request.url.queryParameters.containsKey('state')
      ? request.url.queryParameters['state']
      : '';

  if (stateString.isEmpty) {
    return new Future.value(new shelf.Response.internalServerError(
        body: 'State parameter is missing "${request.url}"'));
  }

  log.finest('stateString:$stateString');


  final Uri returnUrl = Uri.parse(stateString);
  final Map postBody = {
    "grant_type": "authorization_code",
    "code": request.url.queryParameters['code'],
    "redirect_uri": json.config.redirectUri.toString(),
    "client_id": json.config.clientId,
    "client_secret": json.config.clientSecret
  };

  log.finest(
      'Sending request to google. "${tokenEndpoint}" body "${postBody}"');

  //Now we have the "code" which will be exchanged to a token.
  return httpClient.postForm(tokenEndpoint, postBody).then((String response) {
    Map json = JSON.decode(response);

    if (json.containsKey('error')) {
      return new shelf.Response.internalServerError(
          body: 'authenticationserver.router.oauthCallback() '
          'Authentication failed. "${json}"');
    } else {
      ///FIXME: Change to use format from framework AND update the dummy tokens.
      json['expiresAt'] =
          new DateTime.now().add(Configuration.authServer.tokenexpiretime).toString();
      return getUserInfo(json['access_token']).then((Map userData) {
        if (userData == null || userData.isEmpty) {
          log.finest('authenticationserver.router.oauthCallback() '
              'token:"${json['access_token']}" userdata:"${userData}"');

          return new shelf.Response.forbidden(
              JSON.encode(const {'status': 'Forbidden'}));
        } else {
          json['identity'] = userData;

          String cacheObject = JSON.encode(json);
          String hash = Sha256Token(cacheObject);

          try {
            vault.insertToken(hash, json);
            Map queryParameters = {'settoken': hash};

            return new shelf.Response.found(new Uri(
                scheme: returnUrl.scheme,
                userInfo: returnUrl.userInfo,
                host: returnUrl.host,
                port: returnUrl.port,
                path: returnUrl.path,
                queryParameters: queryParameters));
          } catch (error, stackTrace) {
            log.severe(error, stackTrace);

            return new shelf.Response.internalServerError(
                body: 'authenticationserver.router.oauthCallback '
                'uri ${request.url} error: "${error}" data: "$json"');
          }
        }
      }).catchError((error, stackTrace) {
        log.severe(error, stackTrace);
        return new shelf.Response.forbidden(
            JSON.encode(const {'status': 'Forbidden'}));
      });
    }
  }).catchError((error, stackTrace) {
    log.severe(error, stackTrace);

    return new shelf.Response.internalServerError(
        body: 'authenticationserver.router.oauthCallback uri ${request.url} error: "${error}"');
  });
}

/**
 * Asks google for the user data, for the user bound to the [access_token].
 */
Future<Map> getUserInfo(String access_token) {
  Uri url = Uri.parse('https://www.googleapis.com/oauth2/'
      'v1/userinfo?alt=json&access_token=${access_token}');

  return httpClient.get(url).then((String response) {
    Map googleProfile = JSON.decode(response);
    return db.getUser(googleProfile['email']).then((Map agent) {
      if (agent.isNotEmpty) {
        agent['remote_attributes'] = googleProfile;
        return agent;
      } else {
        return null;
      }
    });
  });
}
