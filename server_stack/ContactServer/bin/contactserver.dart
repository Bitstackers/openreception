import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../lib/cache.dart' as cache;
import 'package:OpenReceptionFramework/common.dart';
import '../lib/configuration.dart';
import '../lib/database.dart';
import 'package:OpenReceptionFramework/httpserver.dart' as http;
import '../lib/router.dart' as router;

ArgResults parsedArgs;
ArgParser  parser = new ArgParser();

void main(List<String> args) {
  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if(showHelp()) {
      print(parser.getUsage());
    } else {
      config = new Configuration(parsedArgs);
      config.whenLoaded()
        .then((_) => handleLogger())
        .then((_) => log(config.toString()))
        .then((_) => cache.setup())
        .then((_) => startDatabase())
        .then((_) => http.start(config.httpport, router.setup))
        .catchError((e) => log('main() -> config.whenLoaded() ${e}'));
    }
  } on ArgumentError catch(e) {
    log('main() ArgumentError ${e}.');
    print(parser.getUsage());

  } on FormatException catch(e) {
    log('main() FormatException ${e}');
    print(parser.getUsage());

  } catch(e) {
    log('main() exception ${e}');
  }
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser.addFlag  ('help', abbr: 'h', help: 'Output this help');
  parser.addOption('authurl',         help: 'The http address for the authentication service.');
  parser.addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 8080');
  parser.addOption('dbuser',          help: 'The database user');
  parser.addOption('dbpassword',      help: 'The database password');
  parser.addOption('dbhost',          help: 'The database host. Defaults to localhost');
  parser.addOption('dbport',          help: 'The database port. Defaults to 5432');
  parser.addOption('dbname',          help: 'The database name');
  parser.addOption('cache',           help: 'The location for cache');
  parser.addFlag('syslog',            help: 'Enable logging by syslog', defaultsTo: false);
  parser.addOption('sysloghost',      help: 'The syslog host. Defaults to localhost');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];

Future handleLogger() => config.useSyslog ? activateSyslog(config.syslogHost) : new Future.value(null);
