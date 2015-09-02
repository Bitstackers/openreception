library messagedispatcher.router;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart' as json;
import '../configuration.dart';
import 'package:openreception_framework/httpserver.dart';

import 'package:openreception_framework/database.dart'   as Database;
import 'package:openreception_framework/model.dart'      as Model;
import 'package:openreception_framework/storage.dart'    as Storage;
import 'package:openreception_framework/service.dart'    as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

part 'router/message-queue-single.dart';
part 'router/message-queue-list.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern messageQueueListResource = new UrlPattern(r'/message/queue/list');
final Pattern messageQueueItemResource = new UrlPattern(r'/message/queue/(\d+)');
final Pattern messageDispatchAllResource = new UrlPattern(r'/message/queue/dispatchAll');

final List<Pattern> allUniqueUrls = [messageQueueListResource, messageQueueItemResource, messageDispatchAllResource];

Router setup(HttpServer server) =>
  new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(json.config.authUrl))
    ..serve(messageQueueListResource,   method: 'GET'   ).listen(messageQueueList)
    ..serve(messageDispatchAllResource, method: 'GET'   ).listen(messageDispatchAll)

    //..serve(messageQueueItemResource, method: 'GET'   ).listen(messageQueueSingle)
   ..serve(anything, method: 'OPTIONS').listen(preFlight)
   ..defaultStream.listen(page404);

Database.Connection connection = null;

Storage.Message      messageStore;
Storage.MessageQueue messageQueueStore;

Service.NotificationService Notification = null;

void connectNotificationService() {
  Notification = new Service.NotificationService
      (json.config.notificationServer, Configuration.messageDispatcher.serverToken, new Service_IO.Client());
}

Future startDatabase() =>
    Database.Connection.connect('postgres://${json.config.dbuser}:${json.config.dbpassword}@${json.config.dbhost}:${json.config.dbport}/${json.config.dbname}')
      .then((Database.Connection newConnection) {
        connection = newConnection;
        messageStore     = new Database.Message(connection);
        messageQueueStore = new Database.MessageQueue(connection);
      });
