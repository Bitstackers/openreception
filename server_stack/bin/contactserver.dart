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

library openreception.server.contact;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import 'package:openreception.server/contact_server/router.dart' as router;
import 'package:openreception.server/configuration.dart';

Logger log = new Logger('ContactServer');
ArgResults parsedArgs;
ArgParser parser = new ArgParser();

/**
 * The OR-Stack contact server. Provides a REST interface for retrieving and
 * manipulating contacts.
 */
Future main(List<String> args) async {
  ///Init logging.
  Logger.root.level = config.contactServer.log.level;
  Logger.root.onRecord.listen(config.contactServer.log.onRecord);

  ///Handle argument parsing.
  final ArgParser parser = new ArgParser()
    ..addFlag('help', help: 'Output this help', negatable: false)
    ..addOption('filestore', abbr: 'f', help: 'Path to the filestore backend')
    ..addOption('httpport',
        abbr: 'p',
        defaultsTo: config.contactServer.httpPort.toString(),
        help: 'The port the HTTP server listens on.')
    ..addOption('host',
        abbr: 'h',
        defaultsTo: config.contactServer.externalHostName,
        help: 'The hostname or IP listen-address for the HTTP server')
    ..addOption('auth-uri',
        defaultsTo: config.authServer.externalUri.toString(),
        help: 'The uri of the authentication server')
    ..addOption('notification-uri',
        defaultsTo: config.notificationServer.externalUri.toString(),
        help: 'The uri of the notification server');

  final ArgResults parsedArgs = parser.parse(args);

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
      port: int.parse(parsedArgs['httpport']),
      authUri: Uri.parse(parsedArgs['auth-uri']),
      notificationUri: Uri.parse(parsedArgs['notification-uri']),
      filepath: parsedArgs['filestore']);
  log.info('Ready to handle requests');
}
