library miscserver.router;

import 'dart:io';
import 'dart:convert';

import 'package:route/server.dart';

import 'configuration.dart';
import 'package:openreception_framework/httpserver.dart';

part 'router/getconfiguration.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern configurationUrl = new UrlPattern('/configuration');

void setup(HttpServer server) {
  Router router = new Router(server)
    ..serve(configurationUrl, method: 'GET').listen(getBobConfig)
    ..serve(anything, method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);
}
