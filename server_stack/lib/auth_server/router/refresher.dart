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

part of openreception_servers.authentication.router;

Future<shelf.Response> refresher(shelf.Request request) async {
  final String token =
      shelf_route.getPathParameters(request).containsKey('token')
          ? shelf_route.getPathParameter(request, 'token')
          : '';

  try {
    Map content = vault.getToken(token);

    String refreshToken = content['refresh_token'];

    Uri url = Uri.parse('https://www.googleapis.com/oauth2/v3/token');
    Map body = {
      'refresh_token': refreshToken,
      'client_id': config.authServer.clientId,
      'client_secret': config.authServer.clientSecret,
      'grant_type': 'refresh_token'
    };

    final String response = await httpClient.post(url, JSON.encode(body));

    return new shelf.Response.ok(
        'BODY \n ==== \n${JSON.encode(body)} \n\n RESPONSE '
        '\n ======== \n ${response}');
  } catch (error, stackTrace) {
    log.severe(error, stackTrace);

    return new shelf.Response.internalServerError(body: '$error');
  }
}
