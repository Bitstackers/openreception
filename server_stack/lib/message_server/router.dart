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

library openreception.server.router.message;

import 'dart:async';
import 'dart:io' as io;

import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/response_utils.dart';
import 'controller.dart' as controller;

import 'package:logging/logging.dart';
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-io.dart' as transport;
import 'package:openreception_framework/filestore.dart' as filestore;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

const String libraryName = 'router.';

Future<io.HttpServer> start(
    {String hostname: 'localhost',
    int port,
    String filepath: '',
    Uri authUri,
    Uri notificationUri}) {
  final _authService = new service.Authentication(
      authUri, config.messageServer.serverToken, new transport.Client());

  final Logger _log = new Logger(libraryName);
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
      _log.severe(
          'Authentication validation lookup failed: $error:$stackTrace');

      return new shelf.Response.internalServerError(body: error.toString());
    }

    /// Do not intercept the request, but let the next handler take care of it.
    return null;
  }

  shelf.Middleware checkAuthentication = shelf.createMiddleware(
      requestHandler: _lookupToken, responseHandler: null);

  final _notification = new service.NotificationService(notificationUri,
      config.messageServer.serverToken, new transport.Client());

  final filestore.Message _messageStore =
      new filestore.Message(path: filepath + '/message_queue');

  final controller.Message msgController =
      new controller.Message(_messageStore, _authService, _notification);

  final router = shelf_route.router()
    ..get('/message/list', msgController.list)
    ..get('/message/{mid}', msgController.get)
    ..put('/message/{mid}', msgController.update)
    ..delete('/message/{mid}', msgController.remove)
    ..post('/message/{mid}/send', msgController.send)
    ..post('/message', msgController.create);

  final handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  _log.fine('Using server on $authUri as authentication backend');
  _log.fine('Using server on $notificationUri as notification backend');
  _log.fine('Accepting incoming REST requests on http://$hostname:$port');
  _log.fine('Serving routes:');
  shelf_route.printRoutes(router, printer: (String item) => _log.fine(item));

  return shelf_io.serve(handler, hostname, port);
}
