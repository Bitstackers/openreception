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

library openreception.calendar_server.router;

import 'dart:async';
import 'dart:io' as io;

import '../configuration.dart';
import '../response_utils.dart';

import 'controller.dart' as controller;

import 'package:logging/logging.dart';
import 'package:openreception_framework/storage.dart' as Storage;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;
import 'package:openreception_framework/filestore.dart' as filestore;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

final Logger _log = new Logger('calendarserver.router');

Future<io.HttpServer> start(
    {String hostname: '0.0.0.0', int port: 4110, String filepath: ''}) async {
  final Service.Authentication _authService = new Service.Authentication(
      config.authServer.externalUri,
      config.userServer.serverToken,
      new Service_IO.Client());

  /**
       * Validate a token by looking it up on the authentication server.
       */
  Future<shelf.Response> _lookupToken(shelf.Request request) async {
    var token = request.requestedUri.queryParameters['token'];

    try {
      await _authService.validate(token);
    } on Storage.NotFound {
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

  /**
   * Authentication middleware.
   */
  shelf.Middleware checkAuthentication = shelf.createMiddleware(
      requestHandler: _lookupToken, responseHandler: null);

  /**
   * Controllers.
   */

  final filestore.Calendar _calendarStore =
      new filestore.Calendar(path: filepath + '/calender');

  Service.NotificationService _notification = new Service.NotificationService(
      config.notificationServer.externalUri,
      config.calendarServer.serverToken,
      new Service_IO.Client());

  final controller.Calendar calendarController =
      new controller.Calendar(_calendarStore, _authService, _notification);

  var router = shelf_route.router()
    ..get('/calendar/{type}:{oid}', calendarController.list)
    ..get('/calendar/{type}:{oid}/deleted', calendarController.listDeleted)
    ..get('/calendarentry/{eid}', calendarController.get)
    ..get('/calendarentry/{eid}/deleted', calendarController.getDeleted)
    ..put('/calendarentry/{eid}', calendarController.update)
    ..delete('/calendarentry/{eid}', calendarController.remove)
    ..post('/calendarentry', calendarController.create)
    ..get('/calendarentry/{eid}/change/latest', calendarController.changeLatest)
    ..get('/calendarentry/{eid}/change', calendarController.changes);

  var handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  _log.fine('Serving interfaces on port $port:');
  shelf_route.printRoutes(router, printer: (String item) => _log.fine(item));

  return await shelf_io.serve(handler, hostname, port);
}
