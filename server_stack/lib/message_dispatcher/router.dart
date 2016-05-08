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

import 'package:openreception.framework/filestore.dart' as database;

import 'package:openreception.server/configuration.dart';
import 'controller.dart' as Controller;

final Logger log = new Logger('message_dispatcher.router');

shelf.Middleware addCORSHeaders =
    shelf.createMiddleware(requestHandler: _options, responseHandler: _cors);

const Map<String, String> textHtmlHeader = const {
  IO.HttpHeaders.CONTENT_TYPE: 'text/html'
};
const Map<String, String> corsHeader = const {
  'Access-Control-Allow-Origin': '*'
};

shelf.Response _options(shelf.Request request) => (request.method == 'OPTIONS')
    ? new shelf.Response.ok(null, headers: corsHeader)
    : null;

shelf.Response _cors(shelf.Response response) =>
    response.change(headers: corsHeader);

database.MessageQueue messageQueueStore;
database.Message messageStore;
database.User userStore;

Future<IO.HttpServer> start(
    {String hostname: '0.0.0.0', int port: 4060, String filepath: ''}) async {
  final database.MessageQueue mqdb =
      new database.MessageQueue(filepath + '/message_queue');
  messageStore = new database.Message(filepath + '/message');
  userStore = new database.User(filepath + '/user');
  messageQueueStore = mqdb;
  final Controller.MessageQueue mq = new Controller.MessageQueue(mqdb);

  var router = shelf_route.router()..get('/messagequeue', mq.list);

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests(logger: config.accessLog.onAccess))
      .addMiddleware(addCORSHeaders)
      .addHandler(router.handler);

  log.fine('Accepting incoming requests on $hostname:$port:');
  shelf_route.printRoutes(router, printer: (String item) => log.fine(item));

  return await shelf_io.serve(handler, hostname, port);
}
