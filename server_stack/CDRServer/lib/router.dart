library cdrserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'database.dart' as db;
import 'model.dart';
import 'package:OpenReceptionFramework/httpserver.dart';

part 'router/cdr.dart';
part 'router/newcdr.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern cdrResource = new UrlPattern(r'/cdr');
final Pattern newcdrResource = new UrlPattern(r'/newcdr');

final List<Pattern> allUniqueUrls = [cdrResource];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(cdrResource,    method: 'GET').listen(cdrHandler)
    ..serve(newcdrResource, method: 'POST').listen(insertCdrData)
    ..serve(anything,       method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);
}

