import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../lib/cache.dart' as cache;
import 'package:openreception_framework/common.dart';
import '../lib/configuration.dart';
import '../lib/database.dart';
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/router.dart' as router;

ArgResults    parsedArgs;
ArgParser     parser = new ArgParser();

void main(List<String> args) {
  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if(showHelp()) {
      print(parser.usage);
    } else {
      config = new Configuration(parsedArgs);
      config.whenLoaded()
        .then((_) => router.connectNotificationService())
        .then((_) => handleLogger())
        .then((_) => log(config.toString()))
        .then((_) => cache.setup())
        .then((_) => startDatabase())
        .then((_) => http.start(config.httpport, router.setup))
        .catchError((e) {
          log('main() -> config.whenLoaded() ${e}');
          throw e;
        });
    }
  } on ArgumentError catch(e) {
    log('main() ArgumentError ${e}.');
    print(parser.usage);

  } on FormatException catch(e) {
    log('main() FormatException ${e}');
    print(parser.usage);

  } catch(e) {
    log('main() exception ${e}');
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

Future handleLogger() => config.useSyslog ? activateSyslog(config.syslogHost) : new Future.value(null);
