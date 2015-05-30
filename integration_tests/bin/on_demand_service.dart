library receptionserver.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as IO;

import 'package:logging/logging.dart';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

import '../lib/config.dart';
import '../lib/or_test_fw.dart' as test_fw;
import '../lib/on_demand_handlers.dart' as handler;

const String libraryName = 'support_tools.on_demand_service';
final Logger log = new Logger (libraryName);

shelf.Middleware checkAuthentication =
  shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);


shelf.Response _lookupToken(shelf.Request request) {
  var token = request.requestedUri.queryParameters['token'];

  if (token != Config.magicRESTToken) {
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
    handler.Receptionist receptionistHandler,
    handler.Customer customerHandler,
    {String hostname : '0.0.0.0', int port : 4224}) {
  var router = shelf_route.router()
    ..post('/resource/receptionist/aquire', receptionistHandler.aquire)
    ..post('/resource/receptionist/{rid}/release', receptionistHandler.release)
    ..get('/resource/receptionist/{rid}', receptionistHandler.get)
    ..post('/resource/customer/aquire', customerHandler.aquire)
    ..post('/resource/customer/{cid}/release', customerHandler.release)
    ..post('/resource/customer/{cid}/dial/{extension}', customerHandler.dial)
    ..post('/resource/customer/{cid}/hangupAll', customerHandler.hangupAll)
    ..get('/resource/customer/{cid}', customerHandler.get);

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf_cors.createCorsHeadersMiddleware())
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger : _accessLogger))
      .addHandler(router.handler);

  log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer : log.fine);

  return shelf_io.serve(handler, hostname, port);
}


void main ()  {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  test_fw.SupportTools st;
  handler.Receptionist receptionistHandler;
  handler.Customer customerHandler;

  void setupHandlers() {
    receptionistHandler = new handler.Receptionist(test_fw.ReceptionistPool.instance);
    customerHandler = new handler.Customer(test_fw.CustomerPool.instance);
  }

  test_fw.SupportTools.instance
    .then((test_fw.SupportTools init) => st = init)
    .then((_) => print(st))
    .then((_) => setupHandlers())
    .then((_) => start
      (receptionistHandler, customerHandler,
       hostname: Config.listenRESTAddress,
       port: Config.listenRESTport));
}
