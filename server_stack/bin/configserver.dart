import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

import '../lib/config_server/configuration.dart' as json_conf;
import '../lib/configuration.dart';
import '../lib/config_server/router.dart' as router;

ArgResults    parsedArgs;
ArgParser     parser = new ArgParser();
final Logger  log = new Logger ('configserver');

void main(List<String> args) {
  ///Init logging.
  Logger.root.level = Configuration.configserver.log.level;
  Logger.root.onRecord.listen(Configuration.configserver.log.onRecord);

  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if(showHelp()) {
      print(parser.usage);
    } else {
      json_conf.config = new json_conf.Configuration(parsedArgs);
      json_conf.config.whenLoaded()
        .then((_) => router.start(port : json_conf.config.httpport))
        .catchError(log.shout);
    }
  } catch(error, stackTrace) {
    log.shout(error, stackTrace);
  }
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser.addFlag  ('help', abbr: 'h', help: 'Output this help');
  parser.addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport',        help: 'The port the HTTP server listens on.'
     'Defaults to ${Configuration.configserver.defaults.HttpPort}');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
