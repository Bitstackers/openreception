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
import 'dart:convert';

import 'dart:io' as IO;

import '../configuration.dart';

import 'database.dart' as db;

import 'package:logging/logging.dart';
import 'package:openreception_framework/database.dart'   as Database;
import 'package:openreception_framework/model.dart'      as Model;
import 'package:openreception_framework/event.dart'      as Event;
import 'package:openreception_framework/storage.dart'    as Storage;
import 'package:openreception_framework/service.dart'    as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

part 'router/organization.dart';
part 'router/reception-calendar.dart';
part 'router/reception.dart';

const String libraryName = 'receptionserver.router';
final Logger log = new Logger (libraryName);

Database.Connection _connection = null;
Service.Authentication      _authService  = null;
Service.NotificationService _notification = null;
Database.Organization _organizationDB = new Database.Organization (_connection);
Database.Reception _receptionDB = new Database.Reception (_connection);


void connectAuthService() {
  _authService = new Service.Authentication
      (config.authServer.externalUri, config.userServer.serverToken, new Service_IO.Client());
}

void connectNotificationService() {
  _notification = new Service.NotificationService
      (config.notificationServer.externalUri, config.userServer.serverToken, new Service_IO.Client());
}

Future startDatabase() =>
  Database.Connection.connect(config.database.dsn)
    .then((Database.Connection newConnection) => _connection = newConnection);

shelf.Middleware checkAuthentication =
  shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);


Future<shelf.Response> _lookupToken(shelf.Request request) {
  var token = request.requestedUri.queryParameters['token'];

  return _authService.validate(token).then((_) => null)
  .catchError((error) {
    if (error is Storage.NotFound) {
      return new shelf.Response.forbidden('Invalid token');
    }
    else if (error is IO.SocketException) {
      return new shelf.Response.internalServerError(body : 'Cannot reach authserver');
    }
    else {
      return new shelf.Response.internalServerError(body : error.toString());
    }
  });
}

final Map corsHeaders =
  {'Access-Control-Allow-Origin': '*' ,
   'Access-Control-Allow-Methods' : 'GET, PUT, POST, DELETE'};


/// Simple access logging.
void _accessLogger(String msg, bool isError) {
  if (isError) {
    log.severe(msg);
  } else {
    log.finest(msg);
  }
}

Future<IO.HttpServer> start({String hostname : '0.0.0.0', int port : 4010}) {
  var router = shelf_route.router()
    ..get('/organization', Organization.list)
    ..post('/organization', Organization.create)
    ..get('/organization/{oid}', Organization.get)
    ..put('/organization/{oid}', Organization.update)
    ..delete('/organization/{oid}', Organization.remove)
    ..get('/organization/{oid}/contact', Organization.contacts)
    ..get('/organization/{oid}/reception', Organization.receptions)
    ..get('/reception', Reception.list)
    ..post('/reception', Reception.create)
    ..get('/reception/{rid}', Reception.get)
    ..get('/reception/extension/{exten}', Reception.getByExtension)
    ..get('/reception/{rid}/extension', Reception.extensionOf)
    ..put('/reception/{oid}', Reception.update)
    ..delete('/reception/{oid}', Reception.remove)
    ..get('/reception/{rid}/calendar', ReceptionCalendar.list)
    ..get('/reception/{rid}/calendar/event/{eid}', ReceptionCalendar.get)
    ..put('/reception/{rid}/calendar/event/{eid}', ReceptionCalendar.update)
    ..post('/reception/{rid}/calendar', ReceptionCalendar.create)
    ..delete('/reception/{rid}/calendar/event/{eid}', ReceptionCalendar.remove)
    ..get('/calendarentry/{eid}/change', ReceptionCalendar.listChanges)
    ..get('/calendarentry/{eid}/change/latest', ReceptionCalendar.latestChange);
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf_cors.createCorsHeadersMiddleware(corsHeaders : corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger : _accessLogger))
      .addHandler(router.handler);

  log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer : log.fine);

  return shelf_io.serve(handler, hostname, port);
}

String _tokenFrom(shelf.Request request) =>
    request.requestedUri.queryParameters['token'];

