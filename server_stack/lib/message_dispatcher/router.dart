/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.message_dispatcher.router;

import 'dart:async';
import 'dart:io' as IO;

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

import 'package:openreception_framework/database.dart' as database;

import '../configuration.dart';
import 'controller.dart' as Controller;

final Logger log = new Logger ('message_dispatcher.router');

shelf.Middleware addCORSHeaders =
  shelf.createMiddleware(requestHandler: _options, responseHandler: _cors);

const Map<String, String> textHtmlHeader = const {IO.HttpHeaders.CONTENT_TYPE: 'text/html'};
const Map<String, String> CORSHeader = const {'Access-Control-Allow-Origin': '*'};

shelf.Response _options(shelf.Request request) =>
    (request.method == 'OPTIONS')
      ? new shelf.Response.ok(null, headers: CORSHeader)
      : null;

shelf.Response _cors(shelf.Response response) => response.change(headers: CORSHeader);

database.MessageQueue messageQueueStore;
database.Message messageStore;
database.User userStore;

Future<IO.HttpServer> start({String hostname : '0.0.0.0', int port : 4060}) {

  Future setup () =>
    database.Connection.connect(config.database.dsn)
      .then((database.Connection conn) {
    database.MessageQueue mqdb = new database.MessageQueue(conn);
    messageStore = new database.Message(conn);
    userStore = new database.User(conn);
    messageQueueStore = mqdb;
    Controller.MessageQueue mq = new Controller.MessageQueue(mqdb);

    var router = shelf_route.router()
        ..get('/messagequeue', mq.list);

    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
        .addMiddleware(addCORSHeaders)
        .addHandler(router.handler);

    log.fine('Serving interfaces:');
    shelf_route.printRoutes(router, printer : log.fine);

    return handler;
  });

  return setup().then((handler) => shelf_io.serve(handler, hostname, port));
}