library userserver.router;

import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:OpenReceptionFramework/common.dart';
import 'package:OpenReceptionFramework/httpserver.dart';
import 'package:OpenReceptionFramework/model.dart' as Model;
import 'database/database.dart'; 

part 'router/user.dart';
part 'router/group.dart';
part 'router/user-auth_identity.dart';

final String libraryName = "notificationserver.router";

Map<int,List<WebSocket>> clientRegistry = new Map<int,List<WebSocket>>();

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern userListResource = new UrlPattern(r'/user/list');
final Pattern userResource     = new UrlPattern(r'/user/(\d+)');

final List<Pattern> allUniqueUrls = [userListResource];

void registerHandlers(HttpServer server) {
    logger.debugContext("Notification server is running on "
             "'http://${server.address.address}:${config.httpport}/'", "registerHandlers");
    var router = new Router(server);

    router
      ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
      ..serve(userListResource, method : "GET"   ).listen(User.list)
      ..serve(userResource,     method : "GET"   ).listen(User.get)
      ..serve(userResource,     method : "PUT"   ).listen(User.update)
      ..serve(userResource,     method : "DELETE").listen(User.remove)
      ..serve(userResource,     method : "POST"  ).listen(User.add)
      ..serve(anything, method: 'OPTIONS').listen(preFlight)
      ..defaultStream.listen(page404);
}

