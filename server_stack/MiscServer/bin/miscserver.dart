import 'dart:io';
import 'dart:async';

import '../../Shared/common.dart';
import '../lib/configuration.dart';
import '../lib/router.dart' as router;
import '../../Shared/httpserver.dart' as http;

import 'package:args/args.dart';
import 'package:path/path.dart';

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

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
