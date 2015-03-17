import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../lib/auth_server/cache.dart' as cache;
import 'package:openreception_framework/common.dart';
import '../lib/auth_server/configuration.dart';
import '../lib/auth_server/database.dart';
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/auth_server/router.dart' as router;
import '../lib/auth_server/token_vault.dart';
import '../lib/auth_server/token_watcher.dart' as watcher;

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
        .then((_) => handleLogger())
        .then((_) => log(config.toString()))
        .then((_) => cache.setup())
        .then((_) => startDatabase())
        .then((_) => watcher.setup())
        .then((_) => vault.loadFromDirectory(config.serverTokenDir))
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

Future handleLogger() => config.useSyslog ? activateSyslog(config.syslogHost) : new Future.value(null);
