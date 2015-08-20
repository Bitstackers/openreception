library messageserver.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as IO;

import 'configuration.dart';

import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart'   as Model;
import 'package:openreception_framework/event.dart'   as Event;
import 'package:openreception_framework/storage.dart'  as Storage;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;
import 'package:openreception_framework/database.dart' as Database;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;


part 'router/message.dart';

const String libraryName = 'messageserver.router';

final Logger log = new Logger (libraryName);

Database.Connection _connection = null;
Service.Authentication      _authService  = null;
Service.NotificationService _notification = null;
Storage.Message _messageStore = new Database.Message (_connection);

const Map corsHeaders = const
  {'Access-Control-Allow-Origin': '*',
   'Access-Control-Allow-Methods' : 'GET, PUT, POST, DELETE'};

void connectAuthService() {
  _authService = new Service.Authentication
      (config.authUrl, config.serverToken, new Service_IO.Client());
}

void connectNotificationService() {
  _notification = new Service.NotificationService
      (config.notificationServer, config.serverToken, new Service_IO.Client());
}

Future startDatabase() =>
  Database.Connection.connect('postgres://${config.dbuser}:${config.dbpassword}@${config.dbhost}:${config.dbport}/${config.dbname}')
    .then((Database.Connection newConnection) => _connection = newConnection);

shelf.Middleware checkAuthentication =
  shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);

Future<shelf.Response> _lookupToken(shelf.Request request) {
  var token = request.requestedUri.queryParameters['token'];

  return _authService.validate(token).then((_) => null)
  .catchError((error) {
    if (error is Storage.NotFound) {
      return new shelf.Response.forbidden('Invalid token');
    }
    else if (error is IO.SocketException) {
      return new shelf.Response.internalServerError(body : 'Cannot reach authserver');
    }
    else {
      return new shelf.Response.internalServerError(body : error.toString());
    }
  });
}


/// Simple access logging.
void _accessLogger(String msg, bool isError) {
  if (isError) {
    log.severe(msg);
  } else {
    log.finest(msg);
  }
}

Future<IO.HttpServer> start({String hostname : '0.0.0.0', int port : 4010}) {
  var router = shelf_route.router()
    ..get('/message/list', Message.list)
    ..get('/message/{mid}', Message.get)
    ..put('/message/{mid}', Message.update)
    ..post('/message/{mid}/send', Message.send)
    ..post('/message', Message.create);

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf_cors.createCorsHeadersMiddleware(corsHeaders: corsHeaders))
      .addMiddleware(checkAuthentication)
      .addMiddleware(shelf.logRequests(logger : _accessLogger))
      .addHandler(router.handler);

  log.fine('Serving interfaces:');
  shelf_route.printRoutes(router, printer : log.fine);

  return shelf_io.serve(handler, hostname, port);
}

String _tokenFrom(shelf.Request request) =>
    request.requestedUri.queryParameters['token'];

String _filterFrom(shelf.Request request) =>
    request.requestedUri.queryParameters['filter'];
