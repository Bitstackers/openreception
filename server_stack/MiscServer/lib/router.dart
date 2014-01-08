library router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../../Shared/common.dart';
import '../../Shared/httpserver.dart';

import 'package:route/server.dart';

part 'router/getconfiguration.dart';

final Pattern configurationUrl               = new UrlPattern('/configuration');

void setup(HttpServer server) {
  Router router = new Router(server)
    ..serve(configurationUrl, method: 'GET').listen(getBobConfig)
    ..defaultStream.listen(page404);
}
