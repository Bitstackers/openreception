import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../lib/log_server/configuration.dart' as logserver;
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/log_server/router.dart' as router;
import 'package:logging/logging.dart';
import '../lib/configuration.dart';

Logger log = new Logger ('LogServer');

ArgResults parsedArgs;
ArgParser  parser = new ArgParser();

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
      logserver.config = new logserver.Configuration(parsedArgs);
      logserver.config.whenLoaded()
        .then((_) => print(logserver.config))
        .then((_) => logserver.config.validate())
        .then((_) => http.start(logserver.config.httpport, router.setup))
        .catchError((e) => log.shout ('main() -> config.whenLoaded() ${e}'));
    }
  } on ArgumentError catch(e) {
    log.shout ('main() ArgumentError ${e}.');
    print(parser.usage);

  } on FormatException catch(e) {
    log.shout ('main() FormatException ${e}');
    print(parser.usage);

  } catch(e) {
    log.shout ('main() exception ${e}');
  }
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser.addFlag  ('help', abbr: 'h', help: 'Output this help');
  parser.addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 8080');
  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
