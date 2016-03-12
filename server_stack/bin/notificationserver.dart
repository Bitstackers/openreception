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

library openreception.notification_server;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

import '../lib/configuration.dart';
import '../lib/notification_server/router.dart' as router;

Future main(List<String> args) async {
  ///Init logging. Inherit standard values.
  Logger.root.level = config.notificationServer.log.level;
  Logger.root.onRecord.listen(config.notificationServer.log.onRecord);

  Logger log = new Logger('NotificationServer');
  ArgParser parser = new ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Output this help')
    ..addOption('filestore', abbr: 'f', help: 'Path to the filestore backend')
    ..addOption('httpport',
        help: 'The port the HTTP server listens on. '
            'Defaults to ${config.notificationServer.httpPort}',
        defaultsTo: config.notificationServer.httpPort.toString());

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

  await router.connectAuthService();
  await router.start(
      port: int.parse(parsedArgs['httpport']),
      filepath: parsedArgs['filestore']);
  log.info('Ready to handle requests');
}
