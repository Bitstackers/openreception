library router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../../Shared/httpserver.dart';
import 'db.dart' as db;

import 'package:route/server.dart';

part 'router/getdraft.dart';
part 'router/getmessagelist.dart';
part 'router/sendmessage.dart';

final Pattern getMessageDraftUrl = new UrlPattern(r'/message/drafts');
final Pattern getMessageListUrl = new UrlPattern(r'/message/list');
final Pattern getMessageSendUrl = new UrlPattern(r'/message/send');

void setup(HttpServer server) {
  Router router = new Router(server)
    ..serve(getMessageDraftUrl, method: 'GET').listen(getMessageDrafts)
    ..serve(getMessageListUrl, method: 'GET').listen(getMessageList)
    ..serve(getMessageSendUrl, method: 'POST').listen(sendMessage)
    ..defaultStream.listen(page404);
}
