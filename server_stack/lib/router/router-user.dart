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

library openreception.server.router.user;

import 'dart:async';
import 'dart:io' as io;

import 'package:logging/logging.dart';
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/controller/controller-agent_statistics.dart'
    as controller;
import 'package:openreception.server/controller/controller-client_notifier.dart'
    as controller;
import 'package:openreception.server/controller/controller-user.dart'
    as controller;
import 'package:openreception.server/controller/controller-user_state.dart'
    as controller;
import 'package:openreception.server/response_utils.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

class User {
  final Logger _log = new Logger('server.router.user');

  final service.NotificationService _notification;

  final controller.User _userController;
  final controller.AgentStatistics _statsController;
  final controller.UserState _userStateController;

  User(this._notification, this._userController, this._statsController,
      this._userStateController);

  /**
   *
   */
  void bindRoutes(router) {
    router
      ..get('/user/cache', _userController.cacheStats)
      ..delete('/user/cache', _userController.emptyCache)
      ..get('/user/statistics', _statsController.today)
      ..get('/user/statistics/{day}', _statsController.get)
      ..get('/user', _userController.list)
      ..get('/user/history', _userController.history)
      ..get('/user/{uid}', _userController.get)
      ..get('/user/{uid}/history', _userController.objectHistory)
      ..get('/user/{uid}/changelog', _userController.changelog)
      ..put('/user/{uid}', _userController.update)
      ..delete('/user/{uid}', _userController.remove)
      ..get('/user/all/state', _userStateController.list)
      ..get('/user/{uid}/state', _userStateController.get)
      ..get('/user/{uid}/widget', _userStateController.uiState)
      ..post('/user/{uid}/state/{state}', _userStateController.set)
      ..post('/user', _userController.create)
      ..get('/user/identity/{identity}', _userController.userIdentity)
      ..get('/user/identity/{identity}@{domain}', _userController.userIdentity)
      ..get('/group', _userController.groups);
  }

  /**
   * Start the router.
   */
  Future<io.HttpServer> listen({String hostname: '0.0.0.0', int port: 4030}) {
    var router = shelf_route.router();
    bindRoutes(router);

    var handler = const shelf.Pipeline()
        .addMiddleware(
            shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
        .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
        .addHandler(router.handler);

    _log.fine('Using server on ${_notification.host} as notification backend');
    _log.fine('Accepting incoming REST requests on http://$hostname:$port');
    _log.fine('Serving routes:');
    shelf_route.printRoutes(router, printer: (String item) => _log.fine(item));

    return shelf_io.serve(handler, hostname, port);
  }
}
