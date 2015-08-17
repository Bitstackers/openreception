library contactserver.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as IO;

import 'configuration.dart';
import 'database.dart' as db;

import 'package:logging/logging.dart';
import 'package:openreception_framework/database.dart' as Database;
import 'package:openreception_framework/model.dart'   as Model;
import 'package:openreception_framework/event.dart'   as Event;
import 'package:openreception_framework/storage.dart'  as Storage;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;

part 'router/contact-calendar.dart';
part 'router/contact.dart';
part 'router/endpoint.dart';
part 'router/phone.dart';

const String libraryName = 'contactserver.router';
final Logger log = new Logger (libraryName);

Service.Authentication      AuthService  = null;
Service.NotificationService Notification = null;
Database.Endpoint _endpointDB = new Database.Endpoint (db.connection);
//Database.Phone _phoneDB = new Database.Phone (db.connection);

const Map corsHeaders = const
  {'Access-Control-Allow-Origin': '*',
   'Access-Control-Allow-Methods' : 'GET, PUT, POST, DELETE'};

void connectAuthService() {
  AuthService = new Service.Authentication
      (config.authUrl, config.serverToken, new Service_IO.Client());
}

void connectNotificationService() {
  Notification = new Service.NotificationService
      (config.notificationServer, config.serverToken, new Service_IO.Client());
}

shelf.Middleware checkAuthentication =
  shelf.createMiddleware(requestHandler: _lookupToken, responseHandler: null);


Future<shelf.Response> _lookupToken(shelf.Request request) {
  var token = request.requestedUri.queryParameters['token'];

  return AuthService.validate(token).then((_) => null)
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

/**
 * TODO: Add Contact (not just BaseContact) updates.
 */
Future<IO.HttpServer> start({String hostname : '0.0.0.0', int port : 4010}) {
  var router = shelf_route.router()
    ..get('/contact/{cid}/reception/{rid}/endpoints', Endpoint.ofContact)

    ..get('/contact/{cid}/reception/{rid}/endpoint', Endpoint.ofContact)
    ..post('/contact/{cid}/reception/{rid}/endpoint', Endpoint.create)
    ..put('/endpoint/{eid}', Endpoint.update)
    ..delete('/endpoint/{eid}', Endpoint.remove)

    ..get('/contact/{cid}/reception/{rid}/phones', Phone.ofContact)
    ..post('/contact/{cid}/reception/{rid}/phones', Phone.add)
    ..put('/contact/{cid}/reception/{rid}/phones/{eid}', Phone.update)
    ..delete('/contact/{cid}/reception/{rid}/phones/{eid}', Phone.remove)

//    ..get('/contact/{cid}/reception/{rid}/dlist', Contact.distributionList)
//    ..post('/contact/{cid}/reception/{rid}/dlist', Contact.addDistributionList)
//    ..put('/contact/{cid}/reception/{rid}/dlist/{did}', Contact.updateDistributionList)
//    ..delete('/contact/{cid}/reception/{rid}/dlist/{did}', Contact.removeDistributionList)

    ..get('/contact/list/reception/{rid}', Contact.list)
    ..get('/contact/{cid}/reception/{rid}', Contact.get)
    ..get('/contact/{cid}/reception', Contact.receptions)
    ..get('/contact/{cid}/organization', Contact.organizations)
    ..get('/contact/{cid}', Contact.base)
    ..put('/contact/{cid}', Contact.update)
    ..delete('/contact/{cid}', Contact.remove)
    ..get('/contact', Contact.listBase)
    ..post('/contact', Contact.create)
    ..get('/contact/organization/{oid}', Contact.listByOrganization)
    ..get('/contact/reception/{rid}', Contact.list)
    ..get('/contact/{cid}/reception/{rid}/calendar', ContactCalendar.list)
    ..get('/contact/{cid}/reception/{rid}/calendar/event/{eid}', ContactCalendar.get)
    ..put('/contact/{cid}/reception/{rid}/calendar/event/{eid}', ContactCalendar.update)
    ..post('/contact/{cid}/reception/{rid}/calendar', ContactCalendar.create)
    ..delete('/contact/{cid}/reception/{rid}/calendar/event/{eid}', ContactCalendar.remove)
    ..get('/calendarentry/{eid}/change', ContactCalendar.listChanges)
    ..get('/calendarentry/{eid}/change/latest', ContactCalendar.latestChange);


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
