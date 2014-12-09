import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:openreception_framework/common.dart';
import '../lib/configuration.dart';
import 'package:openreception_framework/httpserver.dart' as http;
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
        .then((_)       => router.connectAuthService())
        .then((_)       => http.start(config.httpport, router.registerHandlers))
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
  parser.addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 4200');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
