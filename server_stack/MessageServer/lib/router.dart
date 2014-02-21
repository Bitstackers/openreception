library messageserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:mailer/mailer.dart';
import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'database.dart' as db;
import 'package:Utilities/common.dart';
import 'package:Utilities/httpserver.dart';

part 'router/getdraft.dart';
part 'router/getmessagelist.dart';
part 'router/sendmessage.dart';

final Pattern getMessageDraftUrl = new UrlPattern(r'/message/drafts');
final Pattern getMessageListUrl = new UrlPattern(r'/message/list');
final Pattern getMessageSendUrl = new UrlPattern(r'/message/send');

final List<Pattern> allUniqueUrls = [getMessageDraftUrl, getMessageListUrl, getMessageSendUrl];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(getMessageDraftUrl, method: 'GET').listen(getMessageDrafts)
    ..serve(getMessageListUrl, method: 'GET').listen(getMessageList)
    ..serve(getMessageSendUrl, method: 'POST').listen(sendMessage)
    ..defaultStream.listen(page404);
}
