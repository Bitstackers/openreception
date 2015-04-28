library managementserver;

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

import '../lib/management_server/configuration.dart' as json;
import '../lib/configuration.dart';
import '../lib/management_server/database.dart';
import '../lib/management_server/router.dart';
import '../lib/management_server/utilities/http.dart';

const libraryName = 'managementserver';
Logger log = new Logger ('managementserver.main');

void main(List<String> args) {
  ///Init logging. Inherit standard values.
  Logger.root.level = Configuration.managementServer.log.level;
  Logger.root.onRecord.listen(Configuration.managementServer.log.onRecord);

  Directory.current = dirname(Platform.script.toFilePath());

  ArgParser parser = new ArgParser();
  ArgResults parsedArgs = registerAndParseCommandlineArguments(parser, args);

  if(parsedArgs['help']) {
    print(parser.usage);
  }

  json.config = new json.Configuration(parsedArgs)
    ..parse();
  log.fine(json.config);

  setupDatabase(json.config)
    .then((db) => setupControllers(db, json.config))
    .then((_) => connectNotificationService())
    .then((_) => makeServer(json.config.httpport))
    .then((HttpServer server) {
      setupRoutes(server, json.config);
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

