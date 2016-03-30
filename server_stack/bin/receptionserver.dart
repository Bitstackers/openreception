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

library openreception.server.reception;

import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/reception_server/router.dart' as router;

Future main(List<String> args) async {
  ///Init logging.
  final Logger log = new Logger('reception_server');
  Logger.root.level = config.receptionServer.log.level;
  Logger.root.onRecord.listen(config.receptionServer.log.onRecord);

  ///Handle argument parsing.
  ArgParser parser = new ArgParser()
    ..addFlag('help', help: 'Output this help', negatable: false)
    ..addOption('filestore', abbr: 'f', help: 'Path to the filestore backend')
    ..addOption('httpport',
        abbr: 'p',
        defaultsTo: config.receptionServer.httpPort.toString(),
        help: 'The port the HTTP server listens on.')
    ..addOption('host',
        abbr: 'h',
        defaultsTo: config.receptionServer.externalHostName,
        help: 'The hostname or IP listen-address for the HTTP server')
    ..addOption('auth-uri',
        defaultsTo: config.authServer.externalUri.toString(),
        help: 'The uri of the authentication server')
    ..addOption('notification-uri',
        defaultsTo: config.notificationServer.externalUri.toString(),
        help: 'The uri of the notification server');

  ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  if (parsedArgs['filestore'] == null) {
    print('Filestore path is required');
    print(parser.usage);
    exit(1);
  }

  await router.start(
      hostname: parsedArgs['host'],
      port: int.parse(parsedArgs['httpport']),
      filepath: parsedArgs['filestore'],
      authUri: Uri.parse(parsedArgs['auth-uri']),
      notificationUri: Uri.parse(parsedArgs['notification-uri']));
  log.info('Ready to handle requests');
}
