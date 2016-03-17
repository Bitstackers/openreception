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

library openreception.server.dialplan;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/dialplan_server/router.dart' as router;

Future main(List<String> args) async {
  ///Init logging.
  Logger.root.level = config.dialplanserver.log.level;
  Logger.root.onRecord.listen(config.dialplanserver.log.onRecord);
  Logger log = new Logger('dialplan_server');

  ///Handle argument parsing.
  final ArgParser parser = new ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Output this help', negatable: false)
    ..addOption('filestore', abbr: 'f', help: 'Path to the filestore backend')
    ..addOption('freeswitch-conf-path',
        help: 'Path to the FreeSWITCH conf directory. '
            'Defaults to /etc/freeswitch',
        defaultsTo: '/etc/freeswitch')
    ..addOption('httpport',
        defaultsTo: config.dialplanserver.httpPort.toString(),
        help: 'The port the HTTP server listens on.');

  final ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  final String filepath = parsedArgs['filestore'];
  if (filepath == null || filepath.isEmpty) {
    stderr.writeln('Filestore path is required');
    print('');
    print(parser.usage);
    exit(1);
  }

  int port;
  try {
    port = int.parse(parsedArgs['httpport']);
    if (port < 1 || port > 65535) {
      throw new FormatException();
    }
  } on FormatException {
    stderr.writeln('Bad port argument: ${parsedArgs['httpport']}');
    print('');
    print(parser.usage);
    exit(1);
  }

  await router.start(
      port: port,
      filepath: filepath,
      fsConfPath: parsedArgs['freeswitch-conf-path']);
  log.info('Ready to handle requests');
}
