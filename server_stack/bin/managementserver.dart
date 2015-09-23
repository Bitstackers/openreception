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

library openreception.management_server;

import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import '../lib/configuration.dart';
import '../lib/management_server/database.dart';
import '../lib/management_server/router.dart';
import '../lib/management_server/utilities/http.dart';

const libraryName = 'managementserver';
Logger log = new Logger ('managementserver.main');

void main(List<String> args) {
  ///Init logging. Inherit standard values.
  Logger.root.level = config.managementServer.log.level;
  Logger.root.onRecord.listen(config.managementServer.log.onRecord);

  ArgParser parser = new ArgParser();
  ArgResults parsedArgs = registerAndParseCommandlineArguments(parser, args);

  if(parsedArgs['help']) {
    print(parser.usage);
  }

  setupDatabase(config)
    .then((db) => setupControllers(db, config))
    .then((_) => connectNotificationService())
    .then((_) => makeServer(config.managementServer.httpPort))
    .then((HttpServer server) {
      setupRoutes(server, config);
      log.fine('Server listening on ${server.address}, port ${server.port}');
    });
}

ArgResults registerAndParseCommandlineArguments(ArgParser parser, List<String> arguments) {
  parser
    ..addFlag  ('help', abbr: 'h',    help: 'Output this help')
    ..addOption('authurl',            help: 'The http address for the authentication service. Example http://auth.example.com')
    ..addOption('configfile',         help: 'The JSON configuration file. Defaults to config.json')
    ..addOption('httpport',           help: 'The port the HTTP server listens on.  Defaults to 8080')
    ..addOption('dbuser',             help: 'The database user')
    ..addOption('dbpassword',         help: 'The database password')
    ..addOption('dbhost',             help: 'The database host. Defaults to localhost')
    ..addOption('dbport',             help: 'The database port. Defaults to 5432')
    ..addOption('dbname',             help: 'The database name')
    ..addOption('notificationserver', help: 'The notification server address')
    ..addOption('servertoken',        help : 'Servertoken for authServer.');

  return parser.parse(arguments);
}

