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

library openreception.reception_server;

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

import '../lib/configuration.dart';
import '../lib/reception_server/database.dart';
import '../lib/reception_server/router.dart' as router;

Logger log = new Logger ('ReceptionServer');
ArgResults    parsedArgs;
ArgParser     parser = new ArgParser();

void main(List<String> args) {
  ///Init logging. Inherit standard values.
  Logger.root.level = config.receptionServer.log.level;
  Logger.root.onRecord.listen(config.receptionServer.log.onRecord);

  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if(showHelp()) {
      print(parser.usage);
    } else {
        router.startDatabase();
        router.connectAuthService();
        router.connectNotificationService();
        startDatabase()
        .then((_) => router.start(port : config.receptionServer.httpPort))
        .catchError(log.shout);
    }
  } catch(error, stackTrace) {
    log.shout(error, stackTrace);
  }
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser
    ..addFlag  ('help', abbr: 'h', help: 'Output this help')
    ..addOption('authurl',         help: 'The http address for the authentication service. Example http://auth.example.com')
    ..addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json')
    ..addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 8080')
    ..addOption('dbuser',          help: 'The database user')
    ..addOption('dbpassword',      help: 'The database password')
    ..addOption('dbhost',          help: 'The database host. Defaults to localhost')
    ..addOption('dbport',          help: 'The database port. Defaults to 5432')
    ..addOption('dbname',          help: 'The database name')
    ..addOption('cache',           help: 'The location for cache')
    ..addFlag('syslog',            help: 'Enable logging by syslog', defaultsTo: false)
    ..addOption('sysloghost',      help: 'The syslog host. Defaults to localhost')
    ..addOption('servertoken', help: 'servertoken');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];