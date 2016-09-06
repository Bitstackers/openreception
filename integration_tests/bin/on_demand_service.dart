library receptionserver.router;

import 'dart:async';
import 'dart:io' as IO;

import 'package:logging/logging.dart';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

import '../lib/config.dart';
import 'package:ort/support.dart' as support;
import '../lib/on_demand_handlers.dart' as handler;

const String libraryName = 'support_tools.on_demand_service';
final Logger log = new Logger(libraryName);

shelf.Middleware checkAuthentication =
    shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);

shelf.Response _lookupToken(shelf.Request request) {
  var token = request.requestedUri.queryParameters['token'];

  if (token != config.magicRESTToken) {
    return new shelf.Response.forbidden('Invalid token');
  }

  return null;
}

/// Simple access logging.
void _accessLogger(String msg, bool isError) {
  if (isError) {
    log.severe(msg);
  } else {
    log.finest(msg);
  }
}

Future<IO.HttpServer> start(
    handler.Receptionist receptionistHandler, handler.Customer customerHandler,
    {String hostname: '0.0.0.0', int port: 4224}) {
  var router = shelf_route.router()
    ..post('/resource/receptionist/aquire', receptionistHandler.aquire)
    ..post('/resource/receptionist/{rid}/release', receptionistHandler.release)
    ..get('/resource/receptionist/{rid}', receptionistHandler.get)
    ..post('/resource/customer/aquire', customerHandler.aquire)
    ..post('/resource/customer/{cid}/release', customerHandler.release)
    ..post('/resource/customer/{cid}/pickup', customerHandler.pickup)
    ..post('/resource/customer/{cid}/dial/{extension}', customerHandler.dial)
    ..post('/resource/customer/{cid}/hangupAll', customerHandler.hangupAll)
    ..get('/resource/customer/{cid}', customerHandler.get);

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf_cors.createCorsHeadersMiddleware())
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger: _accessLogger))
      .addHandler(router.handler);

  log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer: log.fine);

  return shelf_io.serve(handler, hostname, port);
}

Future main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

//  support.SupportTools st;
  handler.Receptionist receptionistHandler;
  handler.Customer customerHandler;

  void setupHandlers() {
    receptionistHandler =
        new handler.Receptionist(support.ReceptionistPool.instance);
    customerHandler = new handler.Customer(support.CustomerPool.instance);
  }

  await setupHandlers();
  await start(receptionistHandler, customerHandler,
      hostname: config.listenRESTAddress, port: config.listenRESTport);
}
