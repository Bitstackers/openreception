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

library openreception.notification_server.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/httpserver.dart' as ORhttp;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/event.dart' as Event;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

part 'router/notification.dart';

const String libraryName = "notificationserver.router";

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern notificationSocketResource = new UrlPattern(r'/notifications');
final Pattern broadcastResource = new UrlPattern(r'/broadcast');
final Pattern sendResource = new UrlPattern(r'/send');
final Pattern connectionsResource = new UrlPattern(r'/connection');
final Pattern connectionResource = new UrlPattern(r'/connection/(\d+)');
final Pattern statisticsResource = new UrlPattern(r'/stats');

final List<Pattern> allUniqueUrls = [
  notificationSocketResource,
  broadcastResource,
  sendResource,
  connectionResource,
  connectionsResource,
  statisticsResource
];

Map<int, List<WebSocket>> clientRegistry = new Map<int, List<WebSocket>>();
Service.Authentication AuthService = null;

void connectAuthService() {
  AuthService =
      new Service.Authentication(config.authUrl, '', new Service_IO.Client());
}

void registerHandlers(HttpServer server) {
  Notification.initStats();
  var router = new Router(server);

  router
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(notificationSocketResource, method: "GET").listen(
        Notification.connect) // The upgrade-request is found in the header of a GET request.
    ..serve(broadcastResource, method: "POST").listen(Notification.broadcast)
    ..serve(sendResource, method: "POST").listen(Notification.send)
    ..serve(connectionsResource, method: "GET")
        .listen(Notification.connectionList)
    ..serve(statisticsResource, method: "GET").listen(Notification.statistics)
    ..serve(connectionResource, method: "GET").listen(Notification.connection)
    ..serve(anything, method: 'OPTIONS').listen(ORhttp.preFlight)
    ..defaultStream.listen(ORhttp.page404);
}

Filter auth(Uri authUrl) {
  return (HttpRequest request) {
    if (request.uri.queryParameters.containsKey('token')) return AuthService
        .validate(request.uri.queryParameters['token'])
        .then((_) => true)
        .catchError((_) => false);
    request.response.statusCode = HttpStatus.FORBIDDEN;
    ORhttp.writeAndClose(
        request, JSON.encode({'description': 'Authorization failure.'}));
  };
}
