/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.client_app_server.static_router;

import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

class FileRouter {
  FileRouter();

  Future start(
      {String host: '127.0.0.1',
      int port: 8999,
      String webroot: 'webroot'}) async {
    shelf.Handler fileHandler = createStaticHandler(webroot,
        defaultDocument: 'index.html', serveFilesOutsidePath: true);

    shelf_route.Router router = shelf_route.router(fallbackHandler: fileHandler)
      ..get('/', fileHandler)
      ..get('/contact', fileHandler)
      ..get('/contact/create', fileHandler)
      ..get('/contact/edit/{cid}', fileHandler)
      ..get('/organization', fileHandler)
      ..get('/organization/create', fileHandler)
      ..get('/organization/edit/{oid}', fileHandler)
      ..get('/reception', fileHandler)
      ..get('/reception/create', fileHandler)
      ..get('/reception/edit/{rid}', fileHandler)
      ..get('/ivr', fileHandler)
      ..get('/ivr/create', fileHandler)
      ..get('/ivr/edit/{name}', fileHandler)
      ..get('/dialplan', fileHandler)
      ..get('/dialplan/create', fileHandler)
      ..get('/dialplan/edit/{extension}', fileHandler)
      ..get('/cdr', fileHandler)
      ..get('/message', fileHandler)
      ..get('/speak', fileHandler)
      ..get('/user', fileHandler)
      ..get('/user/create', fileHandler)
      ..get('/user/edit/{uid}', fileHandler);

    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(router.handler);

    return io.serve(handler, host, port).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
    });
  }
}
