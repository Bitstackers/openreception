library notificationserver.router;

import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:OpenReceptionFramework/common.dart';
import 'package:OpenReceptionFramework/httpserver.dart';

part 'router/send.dart';
part 'router/broadcast.dart';
part 'router/notification.dart';

final String libraryName = "notificationserver.router";

Map<int,List<WebSocket>> clientRegistry = new Map<int,List<WebSocket>>();

final Pattern notificationSocketResource = new UrlPattern(r'/notifications');
final Pattern broadcastResource          = new UrlPattern(r'/broadcast');
final Pattern sendResource               = new UrlPattern(r'/send');

final List<Pattern> allUniqueUrls = [notificationSocketResource , broadcastResource, sendResource];

void registerHandlers(HttpServer server) {
    var router = new Router(server);

    router
      ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
      ..serve(notificationSocketResource, method : "GET" ).listen(registerWebsocket) // The upgrade-request is found in the header of a GET request.
      ..serve(         broadcastResource, method : "POST").listen(handleBroadcast)
      ..serve(              sendResource, method : "POST").listen(handleSend);

}

