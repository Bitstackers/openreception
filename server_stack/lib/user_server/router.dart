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

library openreception.user_server.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as IO;

import '../configuration.dart';

import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart'   as Model;
import 'package:openreception_framework/event.dart'   as Event;
import 'package:openreception_framework/storage.dart'  as Storage;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;
import 'package:openreception_framework/database.dart' as Database;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;


part 'router/handler-user.dart';

const String libraryName = 'userserver.router';

final Logger log = new Logger (libraryName);

Database.Connection _connection = null;
Service.Authentication      _authService  = null;
Service.NotificationService _notification = null;
Database.User _userStore = new Database.User (_connection);

const Map corsHeaders = const
  {'Access-Control-Allow-Origin': '*',
   'Access-Control-Allow-Methods' : 'GET, PUT, POST, DELETE'};

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

Future<IO.HttpServer> start({String hostname : '0.0.0.0', int port : 4030}) {

  User userHandler = new User(_userStore);

  var router = shelf_route.router()
    ..get('/user', userHandler.list)
    ..get('/user/{uid}', userHandler.get)
    ..put('/user/{uid}', userHandler.update)
    ..delete('/user/{uid}', userHandler.remove)
    ..post('/user', userHandler.create)

    ..get('/user/{uid}/group', userHandler.userGroups)
    ..post('/user/{uid}/group/{gid}', userHandler.joinGroup)
    ..delete('/user/{uid}/group/{gid}', userHandler.leaveGroup)
    ..get('/user/{uid}/group/{gid}', userHandler.userGroup)
    ..get('/user/{uid}/identity', userHandler.userIdentities)
    ..post('/user/{uid}/identity', userHandler.addIdentity)
    ..delete('/user/{uid}/identity/{identity}', userHandler.removeIdentity)
    ..delete('/user/{uid}/identity/{identity}@{domain}', userHandler.removeIdentity)
    ..get('/group', userHandler.groups) ;

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer : log.fine);

  return shelf_io.serve(handler, hostname, port);
}