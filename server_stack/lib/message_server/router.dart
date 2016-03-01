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

library openreception.message_server.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import '../configuration.dart';

import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/event.dart' as Event;
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;
import 'package:openreception_framework/database.dart' as Database;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

part 'router/message.dart';

const String libraryName = 'messageserver.router';

final Logger log = new Logger(libraryName);

Database.Connection _connection = null;
Service.Authentication _authService = null;
Service.NotificationService _notification = null;
storage.Message _messageStore = new Database.Message(_connection);

const Map<String, String> corsHeaders = const {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
};

void connectAuthService() {
  _authService = new Service.Authentication(config.authServer.externalUri,
      config.messageServer.serverToken, new Service_IO.Client());
}

void connectNotificationService() {
  _notification = new Service.NotificationService(
      config.notificationServer.externalUri,
      config.messageServer.serverToken,
      new Service_IO.Client());
}

Future startDatabase() => Database.Connection
    .connect(config.database.dsn)
    .then((Database.Connection newConnection) => _connection = newConnection);

shelf.Middleware checkAuthentication =
    shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);

/**
     * Validate a token by looking it up on the authentication server.
     */
Future<shelf.Response> _lookupToken(shelf.Request request) async {
  var token = request.requestedUri.queryParameters['token'];

  try {
    await _authService.validate(token);
  } on storage.NotFound {
    return new shelf.Response.forbidden('Invalid token');
  } on io.SocketException {
    return new shelf.Response.internalServerError(
        body: 'Cannot reach authserver');
  } catch (error, stackTrace) {
    log.severe('Authentication validation lookup failed: $error:$stackTrace');

    return new shelf.Response.internalServerError(body: error.toString());
  }

  /// Do not intercept the request, but let the next handler take care of it.
  return null;
}

Future<io.HttpServer> start({String hostname: '0.0.0.0', int port: 4010}) {
  var router = shelf_route.router()
    ..get('/message/list', Message.list)
    ..get('/message/{mid}', Message.get)
    ..put('/message/{mid}', Message.update)
    ..delete('/message/{mid}', Message.remove)
    ..post('/message/{mid}/send', Message.send)
    ..post('/message', Message.create);

  var handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  log.fine('Serving interfaces on port $port:');
  shelf_route.printRoutes(router, printer: (String item) => log.fine(item));

  return shelf_io.serve(handler, hostname, port);
}

String _tokenFrom(shelf.Request request) =>
    request.requestedUri.queryParameters['token'];

String _filterFrom(shelf.Request request) =>
    request.requestedUri.queryParameters['filter'];
