import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

import '../lib/contact_server/configuration.dart' as json;
import '../lib/contact_server/database.dart';
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/contact_server/router.dart' as router;
import '../lib/configuration.dart';

Logger log = new Logger ('ConfigServer');
ArgResults parsedArgs;
ArgParser  parser = new ArgParser();

void main(List<String> args) {

  ///Init logging. Inherit standard values.
  Logger.root.level = Configuration.contactServer.log.level;
  Logger.root.onRecord.listen(Configuration.contactServer.log.onRecord);

  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if(showHelp()) {
      print(parser.usage);
    } else {
      json.config = new json.Configuration(parsedArgs);
      json.config.whenLoaded()
        .then((_) => router.connectAuthService())
        .then((_) => router.connectNotificationService())
        .then((_) => log.finest(json.config.toString()))
        .then((_) => startDatabase())
        .then((_) => http.start(json.config.httpport, router.setup))
        .catchError(log.shout);
    }
  } catch(error, stackTrace) {
    log.severe(error, stackTrace);
  }
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser
    ..addFlag  ('help', abbr: 'h', help: 'Output this help')
    ..addOption('authurl',         help: 'The http address for the authentication service.')
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