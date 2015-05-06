library notificationserver.router;

import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/httpserver.dart' as ORhttp;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

part 'router/notification.dart';

const String libraryName = "notificationserver.router";

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern notificationSocketResource = new UrlPattern(r'/notifications');
final Pattern broadcastResource          = new UrlPattern(r'/broadcast');
final Pattern sendResource               = new UrlPattern(r'/send');
final Pattern statusResource             = new UrlPattern(r'/status');

final List<Pattern> allUniqueUrls = [notificationSocketResource , broadcastResource, sendResource, statusResource];

Map<int,List<WebSocket>> clientRegistry = new Map<int,List<WebSocket>>();
Service.Authentication AuthService = null;

void connectAuthService() {
  AuthService = new Service.Authentication
      (config.authUrl, '', new Service_IO.Client());
}

void registerHandlers(HttpServer server) {
    var router = new Router(server);

    router
      ..filter(matchAny(allUniqueUrls), ORhttp.auth(config.authUrl))
      ..serve(notificationSocketResource, method : "GET" ).listen(Notification.connect) // The upgrade-request is found in the header of a GET request.
      ..serve(         broadcastResource, method : "POST").listen(Notification.broadcast)
      ..serve(              sendResource, method : "POST").listen(Notification.send)
      ..serve(            statusResource, method : "GET" ).listen(Notification.status)
      ..serve(anything, method: 'OPTIONS').listen(ORhttp.preFlight)
      ..defaultStream.listen(ORhttp.page404);
}

