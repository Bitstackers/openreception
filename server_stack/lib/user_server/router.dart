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
import 'dart:io' as io;

import '../configuration.dart';

import 'package:logging/logging.dart';
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-io.dart' as serviceIO;
import 'package:openreception_framework/database.dart' as database;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

import 'controller.dart' as controller;
import 'model.dart' as model;

const String libraryName = 'userserver.router';

final Logger log = new Logger(libraryName);

database.Connection _connection = null;
service.Authentication _authService = null;

const Map corsHeaders = const {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
};

void connectAuthService() {
  _authService = new service.Authentication(config.authServer.externalUri,
      config.userServer.serverToken, new serviceIO.Client());
}

Future startDatabase() => database.Connection
    .connect(config.database.dsn)
    .then((database.Connection newConnection) => _connection = newConnection);

shelf.Middleware checkAuthentication =
    shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);

Future<shelf.Response> _lookupToken(shelf.Request request) {
  var token = request.requestedUri.queryParameters['token'];

  return _authService.validate(token).then((_) => null).catchError((error) {
    if (error is storage.NotFound) {
      return new shelf.Response.forbidden('Invalid token');
    } else if (error is io.SocketException) {
      return new shelf.Response.internalServerError(
          body: 'Cannot reach authserver');
    } else {
      return new shelf.Response.internalServerError(body: error.toString());
    }
  });
}

Future<io.HttpServer> start({String hostname: '0.0.0.0', int port: 4030}) {
  final model.AgentHistory agentHistory = new model.AgentHistory();
  final model.UserStatusList userStatus = new model.UserStatusList();

  final service.NotificationService _notification =
      new service.NotificationService(config.notificationServer.externalUri,
          config.userServer.serverToken, new serviceIO.Client());

  final database.User _userStore = new database.User(_connection);

  controller.User userController =
      new controller.User(_userStore, _notification);

  controller.AgentStatistics _statsController =
      new controller.AgentStatistics(agentHistory);

  controller.UserState userStateController =
      new controller.UserState(agentHistory, userStatus);

  /// Client notification controller.
  final controller.ClientNotifier notifier =
      new controller.ClientNotifier(_notification);
  notifier.userStateSubscribe(userStatus);

  var router = shelf_route.router()
    ..get('/user/all/statistics', _statsController.list)
    ..get('/user/{uid}/statistics', _statsController.get)
    ..get('/user', userController.list)
    ..get('/user/{uid}', userController.get)
    ..put('/user/{uid}', userController.update)
    ..delete('/user/{uid}', userController.remove)
    ..get('/user/all/state', userStateController.list)
    ..get('/user/{uid}/state', userStateController.get)
    ..post('/user/{uid}/state/{state}', userStateController.set)
    ..post('/user', userController.create)
    ..get('/user/{uid}/group', userController.userGroups)
    ..post('/user/{uid}/group/{gid}', userController.joinGroup)
    ..delete('/user/{uid}/group/{gid}', userController.leaveGroup)
    ..get('/user/{uid}/group/{gid}', userController.userGroup)
    ..get('/user/{uid}/identity', userController.userIdentities)
    ..post('/user/{uid}/identity', userController.addIdentity)
    ..delete('/user/{uid}/identity/{identity}', userController.removeIdentity)
    ..delete('/user/{uid}/identity/{identity}@{domain}',
        userController.removeIdentity)
    ..get('/group', userController.groups);

  var handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addHandler(router.handler);

  log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer: log.fine);

  return shelf_io.serve(handler, hostname, port);
}
