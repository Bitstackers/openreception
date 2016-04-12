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

library openreception.reception_server.router;

import 'dart:async';

import 'dart:io' as io;

import '../configuration.dart';
import '../response_utils.dart';
import 'controller.dart' as controller;

import 'package:logging/logging.dart';
import 'package:openreception_framework/filestore.dart' as filestore;
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

const String libraryName = 'receptionserver.router';
final Logger _log = new Logger(libraryName);

Future<io.HttpServer> start(
    {String hostname: '0.0.0.0',
    int port: 4010,
    String filepath: 'json-data',
    Uri authUri,
    Uri notificationUri}) async {
  final Service.Authentication _authService = new Service.Authentication(
      authUri, config.userServer.serverToken, new Service_IO.Client());

  final Service.NotificationService _notification =
      new Service.NotificationService(notificationUri,
          config.userServer.serverToken, new Service_IO.Client());

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

  /**
   * Authentication middleware.
   */
  shelf.Middleware checkAuthentication = shelf.createMiddleware(
      requestHandler: _lookupToken, responseHandler: null);

  /**
   * Controllers.
   */

  final filestore.Reception rStore =
      new filestore.Reception(path: filepath + '/reception');
  final filestore.Contact cStore =
      new filestore.Contact(rStore, path: filepath + '/contact');
  final filestore.Organization oStore = new filestore.Organization(
      cStore, rStore,
      path: filepath + '/organization');

  controller.Organization organization =
      new controller.Organization(oStore, _notification, _authService);

  controller.Reception reception =
      new controller.Reception(rStore, _notification, _authService);

  var router = shelf_route.router()
    ..get('/organization', organization.list)
    ..get('/organization/receptionmap', organization.receptionMap)
    ..post('/organization', organization.create)
    ..get('/organization/history', organization.history)
    ..get('/organization/{oid}', organization.get)
    ..put('/organization/{oid}', organization.update)
    ..delete('/organization/{oid}', organization.remove)
    ..get('/organization/{oid}/history', organization.objectHistory)
    ..get('/organization/{oid}/contact', organization.contacts)
    ..get('/organization/{oid}/reception', organization.receptions)
    ..get('/reception', reception.list)
    ..post('/reception', reception.create)
    ..get('/reception/history', reception.history)
    ..get('/reception/{rid}', reception.get)
    ..get('/reception/extension/{exten}', reception.getByExtension)
    ..get('/reception/{rid}/extension', reception.extensionOf)
    ..put('/reception/{rid}', reception.update)
    ..delete('/reception/{rid}', reception.remove)
    ..get('/reception/{rid}/history', reception.objectHistory);
  var handler = const shelf.Pipeline()
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

  return await shelf_io.serve(handler, hostname, port);
}
