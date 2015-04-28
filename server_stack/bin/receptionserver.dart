import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

import '../lib/reception_server/cache.dart' as cache;
import '../lib/reception_server/configuration.dart' as json;
import '../lib/configuration.dart';
import '../lib/reception_server/database.dart';
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/reception_server/router.dart' as router;

Logger log = new Logger ('ReceptionServer');
ArgResults    parsedArgs;
ArgParser     parser = new ArgParser();

void main(List<String> args) {
  ///Init logging. Inherit standard values.
  Logger.root.level = Configuration.receptionServer.log.level;
  Logger.root.onRecord.listen(Configuration.receptionServer.log.onRecord);

  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if(showHelp()) {
      print(parser.usage);
    } else {
      json.config = new json.Configuration(parsedArgs);
      json.config.whenLoaded()
        .then((_) => router.connectNotificationService())
        .then((_) => log.fine(json.config))
        .then((_) => cache.setup())
        .then((_) => startDatabase())
        .then((_) => http.start(json.config.httpport, router.setup))
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