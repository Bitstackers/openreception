library cdrserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart' as json;
import 'database.dart' as db;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/httpserver.dart';
import 'package:logging/logging.dart';

part 'router/cdr.dart';
part 'router/create_checkpoint.dart';
part 'router/get_checkpoint.dart';
part 'router/newcdr.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern cdrResource = new UrlPattern(r'/cdr');
final Pattern newcdrResource = new UrlPattern(r'/newcdr');
final Pattern checkpointResource = new UrlPattern(r'/checkpoint');

final List<Pattern> allUniqueUrls = [cdrResource, checkpointResource];

final Logger log = new Logger('cdrserver.router');

Router setup(HttpServer server) =>
  new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(json.config.authUrl))
    ..serve(cdrResource,    method: 'GET').listen(cdrHandler)
    ..serve(newcdrResource, method: 'POST').listen(insertCdrData)
    ..serve(checkpointResource, method: 'GET').listen(getCheckpoints)
    ..serve(checkpointResource, method: 'POST').listen(createCheckpoint)
    ..serve(anything,       method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);

