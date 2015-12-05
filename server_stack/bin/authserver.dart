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

/**
 * The OR-Stack authentication server. Provides a REST authentication interface.
 */
library openreception.authentication_server;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import 'package:logging/logging.dart';
import '../lib/configuration.dart';
import '../lib/auth_server/database.dart';
import '../lib/auth_server/router.dart' as router;
import '../lib/auth_server/token_vault.dart';
import '../lib/auth_server/token_watcher.dart' as watcher;

ArgResults parsedArgs;
ArgParser parser = new ArgParser();

Future main(List<String> args) {
  ///Init logging.
  Logger.root.level = config.authServer.log.level;
  Logger.root.onRecord.listen(config.authServer.log.onRecord);

  ///Handle argument parsing.
  final ArgParser parser = new ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Output this help', negatable: false)
    ..addOption('httpport', abbr: 'p',
        help: 'The port the HTTP server listens on.',
        defaultsTo: config.authServer.httpPort.toString())
    ..addOption('servertokendir', abbr: 'd',
        help: 'A location where some predefined tokens will be loaded from.',
        defaultsTo: config.authServer.serverTokendir);

  final ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  return startDatabase()
      .then((_) => watcher.setup())
      .then((_) => vault.loadFromDirectory(parsedArgs['servertokendir']))
      .then((_) => router.start(port: int.parse(parsedArgs['httpport'])))
      .catchError((error, stackTrace) {
        stderr.write('Setup failed! $error $stackTrace');
    });
}
