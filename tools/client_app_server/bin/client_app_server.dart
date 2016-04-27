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

library openreception.client_app_server;

import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';

import 'package:openreception.client_app_server/router.dart';

Future main(List<String> args) async {
  final ArgParser parser = new ArgParser()
    //..addFlag('logging', abbr: 'l', defaultsTo: true, negatable: true)
    ..addOption('hostname', abbr: 'h', defaultsTo: 'localhost')
    ..addOption('port', abbr: 'p', defaultsTo: '8999')
    ..addOption('webroot', abbr: 'd', defaultsTo: 'web', help: '');

  int port;
  String host;
  String webroot;

  try {
    var result = parser.parse(args);
    port = int.parse(result['port']);
    webroot = new Directory(result['webroot']).absolute.path;
    host = result['hostname'];

    if (!new Directory(webroot).existsSync()) {
      throw new FormatException('Directory: $webroot does not exist');
    }
  } on FormatException catch (e) {
    stderr.writeln(e.message + '\n');
    stderr.writeln(parser.usage);

    /* command line usage error */
    exit(64);
  }

  FileRouter router = new FileRouter();

  await router.start(host: host, port: port, webroot: webroot);
}
