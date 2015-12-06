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

library openreception.dialplan_server.router;

import 'dart:async';
import 'dart:io' as IO;

import '../configuration.dart';
import 'controller.dart' as controller;

import 'package:logging/logging.dart';
import 'package:openreception_framework/storage.dart' as Storage;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;
import 'package:openreception_framework/database.dart' as Database;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

final Logger _log = new Logger('dialplanserver.router');

const Map _corsHeaders = const {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
};

Future<IO.HttpServer> start(
    {String hostname: '0.0.0.0', int port: 4030}) async {
  final Service.Authentication _authService = new Service.Authentication(
      config.authServer.externalUri,
      config.userServer.serverToken,
      new Service_IO.Client());

  /**
   * Validate a token by looking it up on the authentication server.
   */
  Future<shelf.Response> _lookupToken(shelf.Request request) {
    var token = request.requestedUri.queryParameters['token'];

    return _authService.validate(token).then((_) => null).catchError((error) {
      if (error is Storage.NotFound) {
        return new shelf.Response.forbidden('Invalid token');
      } else if (error is IO.SocketException) {
        return new shelf.Response.internalServerError(
            body: 'Cannot reach authserver');
      } else {
        return new shelf.Response.internalServerError(body: error.toString());
      }
    });
  }

  /**
   * Authentication middleware.
   */
  shelf.Middleware checkAuthentication = shelf.createMiddleware(
      requestHandler: _lookupToken, responseHandler: null);

  /**
   * Controllers.
   */
  final Database.Connection _connection =
      await Database.Connection.connect(config.database.dsn);

  final Database.Ivr _ivrStore = new Database.Ivr(_connection);
  final Database.ReceptionDialplan _dpStore =
      new Database.ReceptionDialplan(_connection);

  final controller.Ivr ivrHandler = new controller.Ivr(_ivrStore);
  final controller.ReceptionDialplan receptionDialplanHandler =
      new controller.ReceptionDialplan(_dpStore);

  var router = shelf_route.router()
    ..get('/ivr', ivrHandler.list)
    ..get('/ivr/{id}', ivrHandler.get)
    ..put('/ivr/{id}', ivrHandler.update)
    ..delete('/ivr/{id}', ivrHandler.remove)
    ..post('/ivr', ivrHandler.create)

    ..get('/receptiondialplan', receptionDialplanHandler.list)
    ..get('/receptiondialplan/{id}', receptionDialplanHandler.get)
    ..put('/receptiondialplan/{id}', receptionDialplanHandler.update)
    ..delete('/receptiondialplan/{id}', receptionDialplanHandler.remove)
    ..post('/receptiondialplan', receptionDialplanHandler.create)
    ..post('/receptiondialplan/{id}/analyze', receptionDialplanHandler.analyze)
    ..post('/receptiondialplan/{id}/deploy', receptionDialplanHandler.deploy);

  var handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: _corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  _log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer: _log.fine);

  return shelf_io.serve(handler, hostname, port);
}
