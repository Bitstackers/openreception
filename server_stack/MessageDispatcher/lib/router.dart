library messagedispatcher.router;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/httpserver.dart';

import 'package:openreception_framework/database.dart' as Database;
import 'package:openreception_framework/model.dart'    as Model;
import 'package:openreception_framework/storage.dart'  as Storage;

part 'router/message-queue-single.dart';
part 'router/message-queue-list.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
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
   ..serve(anything, method: 'OPTIONS').listen(preFlight)
   ..defaultStream.listen(page404);
}

Database.Connection connection = null;

Storage.Message      messageStore;
Storage.MessageQueue messageQueueStore;

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) {
        connection = newConnection;
        messageStore     = new Database.Message(connection);
        messageQueueStore = new Database.MessageQueue(connection);
      });
