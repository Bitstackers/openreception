library authenticationserver.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as IO;

import 'package:logging/logging.dart';

import 'package:openreception_framework/service-io.dart' as _transport;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

import 'configuration.dart';
import 'database.dart' as db;
import 'googleauth.dart';
import 'token_watcher.dart' as watcher;
import 'token_vault.dart';

part 'router/invalidate.dart';
part 'router/login.dart';
part 'router/oauthcallback.dart';
part 'router/user.dart';
part 'router/validate.dart';

part 'router/refresher.dart';

const String libraryName = 'authserver.router';
final Logger log = new Logger(libraryName);

const Map corsHeaders = const {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
};

_transport.Client httpClient = new _transport.Client();

/// Simple access logging.
void _accessLogger(String msg, bool isError) {
  if (isError) {
    log.severe(msg);
  } else {
    log.finest(msg);
  }
}

Future<IO.HttpServer> start({String hostname: '0.0.0.0', int port: 4050}) {
  var router = shelf_route.router()
    ..get('/token/create', login)
    ..get('/token/oauth2callback', oauthCallback)
    ..get('/token/{token}', userinfo)
    ..get('/token/{token}/validate', validateToken)
    ..post('/token/{token}/invalidate', invalidateToken)
    ..get('/token/{token}/refresh', login);

  var handler = const shelf.Pipeline()
      .addMiddleware(
          shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(shelf.logRequests(logger: _accessLogger))
      .addHandler(router.handler);

  log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer: log.fine);

  return shelf_io.serve(handler, hostname, port);
}
