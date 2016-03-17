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

library openreception.server.router.contact;

import 'dart:async';
import 'dart:io' as io;

import 'package:openreception.server/configuration.dart';
import 'controller.dart' as controller;

import 'package:logging/logging.dart';
import 'package:openreception_framework/filestore.dart' as filestore;
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-io.dart' as transport;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

const String libraryName = 'contactserver.router';
final Logger log = new Logger(libraryName);

const Map<String, String> corsHeaders = const {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
};

/**
 *
 */
Future<io.HttpServer> start(
    {String hostname: '0.0.0.0', int port: 4010, String filepath: ''}) async {
  final service.Authentication _authService = new service.Authentication(
      config.authServer.externalUri,
      config.userServer.serverToken,
      new transport.Client());

  final service.NotificationService _notification =
      new service.NotificationService(config.notificationServer.externalUri,
          config.userServer.serverToken, new transport.Client());

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

  controller.Contact contact =
      new controller.Contact(cStore, _notification, _authService);

  var router = shelf_route.router()
    ..get('/contact/list/reception/{rid}', contact.listByReception)
    ..post('/contact/{cid}/reception/{rid}', contact.addToReception)
    ..put('/contact/{cid}/reception/{rid}', contact.updateInReception)
    ..delete('/contact/{cid}/reception/{rid}', contact.removeFromReception)
    ..get('/contact/{cid}/reception/{rid}', contact.get)
    ..get('/contact/{cid}/reception', contact.receptions)
    ..get('/contact/{cid}/organization', contact.organizations)
    ..get('/contact/{cid}', contact.base)
    ..put('/contact/{cid}', contact.update)
    ..delete('/contact/{cid}', contact.remove)
    ..get('/contact', contact.listBase)
    ..post('/contact', contact.create)
    ..get('/contact/organization/{oid}', contact.listByOrganization)
    ..get('/contact/reception/{rid}', contact.listByReception);

  var handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  log.fine('Serving interfaces on port $port:');
  shelf_route.printRoutes(router, printer: (String item) => log.fine(item));

  return await shelf_io.serve(handler, hostname, port);
}
