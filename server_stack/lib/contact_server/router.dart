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

library openreception.contact_server.router;

import 'dart:async';
import 'dart:io' as io;

import '../configuration.dart';
import 'controller.dart' as controller;

import 'package:logging/logging.dart';
import 'package:openreception_framework/database.dart' as Database;
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

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
 * TODO: Add Contact (not just BaseContact) updates.
 */
Future<io.HttpServer> start(
    {String hostname: '0.0.0.0', int port: 4010}) async {
  final Service.Authentication _authService = new Service.Authentication(
      config.authServer.externalUri,
      config.userServer.serverToken,
      new Service_IO.Client());

  final Service.NotificationService _notification =
      new Service.NotificationService(config.notificationServer.externalUri,
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
  final Database.Connection connection =
      await Database.Connection.connect(config.database.dsn);
  final contactDB = new Database.Contact(connection);
  final endpointDB = new Database.Endpoint(connection);
  final dlistDB = new Database.DistributionList(connection);

  controller.Contact contact = new controller.Contact(contactDB, _notification);
  controller.Endpoint endpoint = new controller.Endpoint(endpointDB);
  controller.Phone phone = new controller.Phone(contactDB);
  controller.DistributionList dList = new controller.DistributionList(dlistDB);

  var router = shelf_route.router()
    ..get('/contact/{cid}/reception/{rid}/endpoints', endpoint.ofContact)
    ..get('/contact/{cid}/reception/{rid}/endpoint', endpoint.ofContact)
    ..post('/contact/{cid}/reception/{rid}/endpoint', endpoint.create)
    ..put('/endpoint/{eid}', endpoint.update)
    ..delete('/endpoint/{eid}', endpoint.remove)
    ..get('/contact/{cid}/reception/{rid}/phones', phone.ofContact)
    ..post('/contact/{cid}/reception/{rid}/phones', phone.add)
    ..put('/contact/{cid}/reception/{rid}/phones/{eid}', phone.update)
    ..delete('/contact/{cid}/reception/{rid}/phones/{eid}', phone.remove)
    ..get('/contact/{cid}/reception/{rid}/dlist', dList.ofContact)
    ..post('/contact/{cid}/reception/{rid}/dlist', dList.addRecipient)
    ..delete('/dlist/{did}', dList.removeRecipient)
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
