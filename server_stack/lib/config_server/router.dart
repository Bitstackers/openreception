library miscserver.router;

import 'dart:async';
import 'dart:io' as IO;
import 'dart:convert';

import 'configuration.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

part 'router/getconfiguration.dart';

final String configurationUrl = '/configuration';
final Logger log = new Logger ('configserver.router');

shelf.Middleware addCORSHeaders =
  shelf.createMiddleware(requestHandler: _options, responseHandler: _cors);

const Map<String, String> textHtmlHeader = const {IO.HttpHeaders.CONTENT_TYPE: 'text/html'};
const Map<String, String> CORSHeader = const {'Access-Control-Allow-Origin': '*'};

shelf.Response _options(shelf.Request request) =>
    (request.method == 'OPTIONS')
      ? new shelf.Response.ok(null, headers: CORSHeader)
      : null;

shelf.Response _cors(shelf.Response response) => response.change(headers: CORSHeader);

/// Simple access logging.
void _accessLogger(String msg, bool isError) {
  if (isError) {
    log.severe(msg);
  } else {
    log.finest(msg);
  }
}
Future<IO.HttpServer> start({String hostname : '0.0.0.0', int port : 8000}) {
  var router = shelf_route.router(fallbackHandler : send404)
      ..get(configurationUrl, getBobConfig);

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests(logger : _accessLogger))
      .addMiddleware(addCORSHeaders)
      .addHandler(router.handler);

  log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer : log.fine);

  return shelf_io.serve(handler, hostname, port);
}
