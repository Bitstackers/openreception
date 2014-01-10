library miscserver.router;

import 'dart:async';
import 'dart:io';

import 'package:route/server.dart';

import 'configuration.dart';
import 'package:Utilities/common.dart';
import 'package:Utilities/httpserver.dart';

part 'router/getconfiguration.dart';

final Pattern configurationUrl = new UrlPattern('/configuration');

void setup(HttpServer server) {
  Router router = new Router(server)
    ..serve(configurationUrl, method: 'GET').listen(getBobConfig)
    ..defaultStream.listen(page404);
}
