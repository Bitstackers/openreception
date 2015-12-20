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

library openreception.dialplan_server;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import '../lib/configuration.dart';
import '../lib/dialplan_server/router.dart' as router;

Future main(List<String> args) {
  ///Init logging.
  final Logger log = new Logger('dialplan_server');
  Logger.root.level = config.dialplanserver.log.level;
  Logger.root.onRecord.listen(config.dialplanserver.log.onRecord);

  ///Handle argument parsing.
  ArgParser parser = new ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Output this help', negatable: false)
    ..addOption('httpport',
        defaultsTo: config.dialplanserver.httpPort.toString(),
        help: 'The port the HTTP server listens on.');

  ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  return router
      .start(port: int.parse(parsedArgs['httpport']))
      .catchError((e,s) => log.shout('Failed to start router: $e $s'));
}