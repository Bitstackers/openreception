library messagedispatcher.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:mailer/mailer.dart';
import 'package:route/pattern.dart';
import 'package:route/server.dart';
import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'database.dart' as db;
import 'package:OpenReceptionFramework/common.dart';
import 'package:OpenReceptionFramework/httpserver.dart';

part 'router/message-queue-single.dart';
part 'router/message-queue-list.dart';


final Pattern messageQueueListResource = new UrlPattern(r'/message/queue/list');
final Pattern messageQueueItemResource = new UrlPattern(r'/message/queue/(\d+)');
final Pattern messageDispatchAllResource = new UrlPattern(r'/message/queue/dispatchAll');

final List<Pattern> allUniqueUrls = [messageQueueListResource, messageQueueItemResource, messageDispatchAllResource];

void setup(HttpServer server) {
  
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(messageQueueListResource,   method: 'GET'   ).listen(messageQueueList)
    ..serve(messageDispatchAllResource, method: 'GET'   ).listen(messageDispatchAll)
    
    //..serve(messageQueueItemResource, method: 'GET'   ).listen(messageQueueSingle)
    ..defaultStream.listen(page404);
}

