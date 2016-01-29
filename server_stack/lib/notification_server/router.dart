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

library openreception.notification_server.router;

import 'dart:async';
import 'dart:io' as io;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';

import '../configuration.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/event.dart' as Event;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;
import 'package:openreception_framework/storage.dart' as Storage;

//import 'package:http_parser/http_parser.dart';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_web_socket/shelf_web_socket.dart' as sWs;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

part 'router/notification.dart';

const String libraryName = "notificationserver.router";
final Logger _log = new Logger(libraryName);

const Map<String, String> corsHeaders = const {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
};

void connectAuthService() {
  _authService = new Service.Authentication(config.authServer.externalUri,
      config.userServer.serverToken, new Service_IO.Client());
}

Future<shelf.Response> _lookupToken(shelf.Request request) {
  var token = request.requestedUri.queryParameters['token'];

  return _authService.validate(token).then((_) => null).catchError((error) {
    if (error is Storage.NotFound) {
      return new shelf.Response.forbidden('Invalid token');
    } else if (error is io.SocketException) {
      return new shelf.Response.internalServerError(
          body: 'Cannot reach authserver');
    } else {
      return new shelf.Response.internalServerError(body: error.toString());
    }
  });
}

shelf.Middleware checkAuthentication =
    shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);

shelf.Response _handleHttpRequest(shelf.Request request) =>
    new shelf.Response.ok('asds');

/**
 *
 */
Future<io.HttpServer> start({String hostname: '0.0.0.0', int port: 4200}) {
  var router = (shelf_route.router()
    ..get('/notifications', Notification._handleWsConnect)
    ..post('/broadcast', Notification.broadcast)
    ..post('/send', Notification.send)
    ..get('/connection', Notification.connectionList)
    ..get('/stats', Notification.statistics)
    ..get('/connection/{uid}', Notification.connection)
    ..get('/rest', _handleHttpRequest));

  var handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  _log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer: (String item) => _log.fine(item));

  return shelf_io.serve(handler, hostname, port);
}

String _tokenFrom(shelf.Request request) =>
    request.requestedUri.queryParameters['token'];

Map<int, List<CompatibleWebSocket>> clientRegistry =
    new Map<int, List<CompatibleWebSocket>>();
Service.Authentication _authService = null;
