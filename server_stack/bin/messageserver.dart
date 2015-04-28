import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:logging/logging.dart';
import '../lib/message_server/configuration.dart' as json;
import '../lib/configuration.dart';
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/message_server/router.dart' as router;

Logger log = new Logger ('MessageServer');
ArgResults parsedArgs;
ArgParser  parser = new ArgParser();

void main(List<String> args) {
  ///Init logging. Inherit standard values.
  Logger.root.level = Configuration.messageServer.log.level;
  Logger.root.onRecord.listen(Configuration.messageServer.log.onRecord);

  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if(showHelp()) {
      print(parser.usage);
    } else {
      json.config = new json.Configuration(parsedArgs);
      json.config.whenLoaded()
        .then((_) => router.connectAuthService())
        .then((_) => router.connectNotificationService())
        .then((_) => router.startDatabase())
        .then((_) => http.start(json.config.httpport, router.setup))
        .catchError(log.shout);
    }
  } catch(error, stackTrace) {
    log.shout(error, stackTrace);
  }
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser.addFlag  ('help', abbr: 'h', help: 'Output this help');
  parser.addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 8080');
  parser.addOption('dbuser',          help: 'The database user');
  parser.addOption('dbpassword',      help: 'The database password');
  parser.addOption('dbhost',          help: 'The database host. Defaults to localhost');
  parser.addOption('dbport',          help: 'The database port. Defaults to 5432');
  parser.addOption('dbname',          help: 'The database name');
  parser.addOption('servertoken',     help: 'Server-Token');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
