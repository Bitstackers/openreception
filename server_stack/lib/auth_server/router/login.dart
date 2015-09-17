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
