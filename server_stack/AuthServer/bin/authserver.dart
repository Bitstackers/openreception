import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../lib/cache.dart' as cache;
import 'package:Utilities/common.dart';
import '../lib/configuration.dart';
import '../lib/database.dart';
import 'package:Utilities/httpserver.dart' as http;
import '../lib/router.dart' as router;
import '../lib/token_watcher.dart' as watcher;

ArgResults    parsedArgs;
ArgParser     parser = new ArgParser();

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
        .then((_) => log(config))
        .then((_) => cache.setup())
        .then((_) => startDatabase())
        .then((_) => watcher.setup())
        .then((_) => http.start(config.httpport, router.setup))
        .catchError((e) { 
          log('main() -> config.whenLoaded() ${e}');
          throw e;
        });
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
  parser.addOption('clientid',        help: 'The client id from google');
  parser.addOption('clientsecret',    help: 'The client secret from google');
  parser.addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 8080');
  parser.addOption('redirecturi',     help: 'The URI google redirects to after an authtication attempt. Defaults to http://localhost:8080/oauth2callback');
  parser.addOption('tokenexpiretime', help: 'The time in seconds a token is valid. Refreshed on use. Defaults to 3600');
  parser.addFlag('syslog',            help: 'Enable logging by syslog', defaultsTo: false);
  parser.addOption('sysloghost',      help: 'The syslog host. Defaults to localhost');
  
  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];

Future handleLogger() => config.useSyslog ? activateSyslog(config.syslogHost) : new Future.value(null);
