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

library openreception.server.cdr;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:openreception.server/router/router-cdr.dart' as router;
import 'package:openreception.server/configuration.dart';

/**
 * CDR server.
 */
Future main(List<String> args) async {
  ///Init logging.
  Logger.root.level = config.cdrServer.log.level;
  Logger.root.onRecord.listen(config.cdrServer.log.onRecord);

  final ArgParser parser = new ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Output this help');
  final ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }
  await router.start(port: config.cdrServer.httpPort);
}
