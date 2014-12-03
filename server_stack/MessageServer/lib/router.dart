library messageserver.router;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;
import 'package:openreception_framework/storage.dart' as Storage;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/database.dart' as Database;
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/httpserver.dart';

part 'router/message-draft.dart';
part 'router/message.dart';

const String libraryName = 'messageserver.router';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern messageDraftListResource    = new UrlPattern(r'/message/draft/list');
final Pattern messageDraftResource        = new UrlPattern(r'/message/draft/(\d+)');
final Pattern messageDraftCreateResource  = new UrlPattern(r'/message/draft/create');
final Pattern messageListSpecificResource = new UrlPattern(r'/message/list/(\d+)/limit/(\d+)');
final Pattern messageListResource         = new UrlPattern(r'/message/list');
final Pattern messageResource             = new UrlPattern(r'/message/(\d+)');
final Pattern messageSendResource         = new UrlPattern(r'/message/send');
final Pattern messageSaveResource         = new UrlPattern(r'/message');
final Pattern messageResendResource       = new UrlPattern(r'/message/(\d+)/send');

final List<Pattern> allUniqueUrls = [messageDraftListResource, messageDraftResource, messageDraftCreateResource,
                                     messageListResource, messageListSpecificResource,
                                     messageResource, messageSaveResource,
                                     messageSendResource, messageResendResource];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(messageDraftResource,        method: 'GET'   ).listen(MessageDraft.get)
    ..serve(messageDraftResource,        method: 'PUT'   ).listen(MessageDraft.update)
    ..serve(messageDraftCreateResource,  method: 'POST'  ).listen(MessageDraft.create)
    ..serve(messageDraftResource,        method: 'DELETE').listen(MessageDraft.delete)
    ..serve(messageDraftListResource,    method: 'GET'   ).listen(MessageDraft.list)
    ..serve(messageResource,             method: 'GET'   ).listen(Message.get)
    ..serve(messageResource,             method: 'PUT'   ).listen(Message.update)
    ..serve(messageListResource,         method: 'GET'   ).listen(Message.listNewest)
    ..serve(messageListSpecificResource, method: 'GET'   ).listen(Message.list)
    ..serve(messageSendResource,         method: 'POST'  ).listen(Message.send)
    ..serve(messageSaveResource,         method: 'POST'  ).listen(Message.save)
    ..serve(messageResendResource,       method: 'POST'  ).listen(Message.send)

    ..serve(anything, method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);
}

Database.Connection connection = null;
Storage.Message messageStore = new Database.Message (connection);
Service.Authentication AuthService = null;
Service.NotificationService Notification = null;

void connectAuthService() {
  AuthService = new Service.Authentication
      (config.authUrl, config.serverToken, new Service_IO.Client());
}

void connectNotificationService() {
  Notification = new Service.NotificationService
      (config.notificationServer, config.serverToken, new Service_IO.Client());
}

Future startDatabase() =>
    Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
      .then((Database.Connection newConnection) => connection = newConnection);
