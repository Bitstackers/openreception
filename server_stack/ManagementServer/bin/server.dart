library managementserver;

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:openreception_framework/common.dart' as orf;

import '../lib/configuration.dart';
import '../lib/database.dart';
import '../lib/router.dart';
import '../lib/utilities/http.dart';

const libraryName = 'managementserver';

void main(List<String> args) {
  const context = '${libraryName}.main';
  Directory.current = dirname(Platform.script.toFilePath());

  ArgParser parser = new ArgParser();
  ArgResults parsedArgs = registerAndParseCommandlineArguments(parser, args);

  if(parsedArgs['help']) {
    print(parser.usage);
  }

  config = new Configuration(parsedArgs)
    ..parse();
  orf.logger.debugContext(config, context);

  setupDatabase(config)
    .then((db) => setupControllers(db, config))
    .then((_) => connectNotificationService())
    .then((_) => makeServer(config.httpport))
    .then((HttpServer server) {
      setupRoutes(server, config);

      orf.logger.debugContext('Server started up!', context);
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

