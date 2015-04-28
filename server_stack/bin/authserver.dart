import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:logging/logging.dart';
import '../lib/auth_server/cache.dart' as cache;
import '../lib/auth_server/configuration.dart' as auth;
import '../lib/configuration.dart';
import '../lib/auth_server/database.dart';
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/auth_server/router.dart' as router;
import '../lib/auth_server/token_vault.dart';
import '../lib/auth_server/token_watcher.dart' as watcher;

ArgResults    parsedArgs;
ArgParser     parser = new ArgParser();

final Logger log = new Logger ('AuthServer');

void main(List<String> args) {

  ///Init logging. Inherit standard values.
  Logger.root.level = Configuration.logDefaults.level;
  Logger.root.onRecord.listen(Configuration.logDefaults.onRecord);

  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if(showHelp()) {
      print(parser.usage);
    } else {
      auth.config = new auth.Configuration(parsedArgs);
      auth.config.whenLoaded()
        .then((_) => log.fine(auth.config.toString()))
        .then((_) => cache.setup())
        .then((_) => startDatabase())
        .then((_) => watcher.setup())
        .then((_) => vault.loadFromDirectory(auth.config.serverTokenDir))
        .then((_) => http.start(auth.config.httpport, router.setup))
        .catchError(log.shout);
    }
  } on ArgumentError catch(e) {
    log.severe('main() ArgumentError ${e}.');
    print (parser.usage);

  } on FormatException catch(e) {
    log.severe('main() FormatException ${e}');
    print(parser.usage);

  } catch(e) {
    log.severe('main() exception ${e}');
  }
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser
    ..addFlag  ('help', abbr: 'h', help: 'Output this help')
    ..addOption('clientid',        help: 'The client id from google')
    ..addOption('clientsecret',    help: 'The client secret from google')
    ..addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json')
    ..addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 8080')
    ..addOption('redirecturi',     help: 'The URI google redirects to after an authtication attempt. Defaults to http://localhost:8080/oauth2callback')
    ..addOption('tokenexpiretime', help: 'The time in seconds a token is valid. Refreshed on use. Defaults to 3600')
    ..addFlag('syslog',            help: 'Enable logging by syslog', defaultsTo: false)
    ..addOption('sysloghost',      help: 'The syslog host. Defaults to localhost')
    ..addOption('servertokendir',  help: 'A location where some predefined tokens will be loaded from.');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
