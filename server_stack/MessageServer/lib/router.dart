library messageserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';
import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'database.dart' as db;
import 'model.dart' as model;
import 'package:OpenReceptionFramework/service.dart' as Service;
import 'package:OpenReceptionFramework/common.dart';
import 'package:OpenReceptionFramework/httpserver.dart';

part 'router/message-draft-single.dart';
part 'router/message-draft-update.dart';
part 'router/message-draft-create.dart';
part 'router/message-draft-delete.dart';
part 'router/message-draft-list.dart';
part 'router/message-list.dart';
part 'router/message-send.dart';
part 'router/message-single.dart';
part 'router/message-resend.dart';

final String libraryName = 'messageserver.router';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern messageDraftListResource   = new UrlPattern(r'/message/draft/list');
final Pattern messageDraftResource       = new UrlPattern(r'/message/draft/(\d+)');
final Pattern messageDraftCreateResource = new UrlPattern(r'/message/draft/create');
final Pattern messageListResource        = new UrlPattern(r'/message/list');
final Pattern messageResource            = new UrlPattern(r'/message/(\d+)');
final Pattern messageSendResource        = new UrlPattern(r'/message/send');
final Pattern messageResendResource      = new UrlPattern(r'/message/(\d+)/resend');

final List<Pattern> allUniqueUrls = [messageDraftListResource, messageDraftResource, messageDraftCreateResource, 
                                     messageListResource, messageResource, messageSendResource, messageResendResource];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    
    ..serve(messageDraftResource,       method: 'GET'   ).listen(messageDraftSingle)
    ..serve(messageDraftResource,       method: 'PUT'   ).listen(messageDraftUpdate)
    ..serve(messageDraftCreateResource, method: 'POST'  ).listen(messageDraftCreate)
    ..serve(messageDraftResource,       method: 'DELETE').listen(messageDraftDelete)
    ..serve(messageDraftListResource,   method: 'GET'   ).listen(messageDraftList)
    
    ..serve(messageResource,            method: 'GET'   ).listen(messageSingle)
    ..serve(messageListResource,        method: 'GET'   ).listen(messageList)
    ..serve(messageSendResource,        method: 'POST'  ).listen(messageSend)
    ..serve(messageResendResource,      method: 'POST'  ).listen(messageResend)
    
    ..serve(anything, method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);
}
