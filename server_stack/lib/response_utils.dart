/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library ors.router.response_utils;

import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;

const Map<String, String> corsHeaders = const {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
};

/**
 *
 */
shelf.Response okJson(body) => ok(JSON.encode(body));

/**
 *
 */
shelf.Response ok(body) => new shelf.Response.ok(body);

/**
 *
 */
shelf.Response okGzip(body) => new shelf.Response.ok(body, headers: {
      'content-encoding': 'gzip',
      'content-type': 'application/json; charset=utf-8'
    });

/**
 *
 */
shelf.Response notFoundJson(body) =>
    new shelf.Response.notFound(JSON.encode(body));

/**
     *
     */
shelf.Response notFound(body) => new shelf.Response.notFound(body);

/**
 *
 */
shelf.Response clientError(String reason) =>
    new shelf.Response(400, body: reason);

/**
 *
 */
shelf.Response clientErrorJson(reason) =>
    new shelf.Response(400, body: JSON.encode(reason));

/**
 *
 */
shelf.Response serverError(String reason) =>
    new shelf.Response(500, body: reason);

shelf.Response authServerDown() =>
    new shelf.Response(502, body: 'Authentication server is not reachable');

String tokenFrom(shelf.Request request) =>
    request.requestedUri.queryParameters['token'];
