library cdrserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'database.dart' as db;
import 'model.dart';
import 'package:openreception_framework/httpserver.dart';

part 'router/cdr.dart';
part 'router/create_checkpoint.dart';
part 'router/get_checkpoint.dart';
part 'router/newcdr.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern cdrResource = new UrlPattern(r'/cdr');
final Pattern newcdrResource = new UrlPattern(r'/newcdr');
final Pattern checkpointResource = new UrlPattern(r'/checkpoint');

final List<Pattern> allUniqueUrls = [cdrResource, checkpointResource];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(cdrResource,    method: 'GET').listen(cdrHandler)
    ..serve(newcdrResource, method: 'POST').listen(insertCdrData)
    ..serve(checkpointResource, method: 'GET').listen(getCheckpoints)
    ..serve(checkpointResource, method: 'PUT').listen(createCheckpoint)
    ..serve(anything,       method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);
}

