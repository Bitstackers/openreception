import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:Utilities/common.dart';
import '../lib/configuration.dart';
import 'package:Utilities/httpserver.dart' as http;
import '../lib/router.dart' as router;
import '../lib/client_socket.dart';

ArgResults parsedArgs;
ArgParser parser = new ArgParser();

void main(List<String> args) {
  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if (showHelp()) {
      print(parser.getUsage());
    } else {
      config = new Configuration(parsedArgs);
      config.whenLoaded()
        .then((_) => http.start(config.httpport, router.registerHandlers))
        .then((_) => connectClient())
        .catchError((e) => log('main() -> config.whenLoaded() ${e}'));
    }
  } on ArgumentError catch (e) {
    log('main() ArgumentError ${e}.');
    print(parser.getUsage());

  } on FormatException catch (e) {
    log('main() FormatException ${e}');
    print(parser.getUsage());

  } catch (e) {
    log('main() exception ${e}');
  }
}

void connectClient() {
  
  Duration period = new Duration(seconds : 3);
  
  print ("Connecting");
  clientSocket.connect(config.callFlowHost, config.callFlowPort).then((clientSocket client) {
    client.listenEventSocket();
  }).catchError((error) {
    print ("Failed to connect, retrying in ${period.inSeconds} seconds.");
      if (error is SocketException) {
        new Timer(period, connectClient);
      }
  });
}


void registerAndParseCommandlineArguments(List<String> arguments) {
  parser.addFlag('help', abbr: 'h', help: 'Output this help');
  parser.addOption('configfile', help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport', help: 'The port the HTTP server listens on.  Defaults to 4243');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
