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

shelf.Response userinfo(shelf.Request request) {
  final String token =
      shelf_route.getPathParameters(request).containsKey('token')
          ? shelf_route.getPathParameter(request, 'token')
          : '';

  try {
    if (token == config.authServer.serverToken) {
      return new shelf.Response.ok(
          JSON.encode(new model.User.empty()..id = model.User.noID));
    }

    Map content = vault.getToken(token);
    try {
      watcher.seen(token);
    } catch (error, stacktrace) {
      log.severe(error, stacktrace);
    }

    if (!content.containsKey('identity')) {
      return new shelf.Response.internalServerError(
          body: 'Parse error in stored map');
    }

    return new shelf.Response.ok(JSON.encode(content['identity']));
  } on storage.NotFound {
    return new shelf.Response.notFound(
        JSON.encode({'Status': 'Token $token not found'}));
  } catch (error, stacktrace) {
    log.severe(error, stacktrace);

    return new shelf.Response.internalServerError(
        body: JSON.encode({'Status': 'Not found'}));
  }
}
