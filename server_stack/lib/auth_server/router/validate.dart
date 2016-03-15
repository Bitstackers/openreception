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

shelf.Response validateToken(shelf.Request request) {
  final String token =
      shelf_route.getPathParameters(request).containsKey('token')
          ? shelf_route.getPathParameter(request, 'token')
          : '';

  if (token.isNotEmpty) {
    if (token == config.authServer.serverToken) {
      return new shelf.Response.ok(JSON.encode(const {}));
    }

    if (vault.containsToken(token)) {
      try {
        watcher.seen(token);
      } catch (error, stacktrace) {
        log.severe(error, stacktrace);
      }

      return new shelf.Response.ok(JSON.encode(const {}));
    } else {
      return new shelf.Response.notFound(JSON.encode(const {}));
    }
  }

  return new shelf.Response(400, body: 'Invalid or missing token passed.');
}
