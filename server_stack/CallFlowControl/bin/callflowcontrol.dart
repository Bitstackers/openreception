import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:openreception_framework/common.dart';
import '../lib/configuration.dart';
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/router.dart' as router;
import '../lib/model/model.dart' as Model;
import 'package:esl/esl.dart' as ESL;
import 'package:logging/logging.dart';


ArgResults parsedArgs;
ArgParser parser = new ArgParser();

void main(List<String> args) {
  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if (showHelp()) {
      print(parser.usage);
    } else {
      config = new Configuration(parsedArgs);
      config.whenLoaded()
        .then((_) => router.connectAuthService())
        .then((_) => router.connectNotificationService())
        .then((_) => connectESLClient())
        .then((_) => http.start(config.httpport, router.registerHandlers))
        .catchError((e) => log('main() -> config.whenLoaded() ${e}'));
    }
  } on ArgumentError catch (e) {
    log('main() ArgumentError ${e}.');
    print(parser.usage);

  } on FormatException catch (e) {
    log('main() FormatException ${e}');
    print(parser.usage);

  } catch (e) {
    log('main() exception ${e}');
  }
}

void connectESLClient() {

  const String context = 'connectClient';

  Duration period = new Duration(seconds : 3);

  logger.infoContext('Connecting to ${config.eslHostname}:${config.eslPort}', context);

  Logger.root.level = Level.ALL;

  Model.PBXClient.instance = new ESL.Connection()..log.onRecord.listen(print);

  Model.CallList.instance.subscribe(Model.PBXClient.instance.eventStream);
  Model.PeerList.subscribe(Model.PBXClient.instance.eventStream);

  /// Respond to server requests.
  Model.PBXClient.instance.requestStream.listen((ESL.Packet packet) {
    switch (packet.contentType) {
      case (ESL.ContentType.Auth_Request):
        Model.PBXClient.instance.authenticate(config.eslPassword)
          .then((_) => Model.PBXClient.instance.event(['all'], format : ESL.EventFormat.Json))
          .then((_) => Model.PBXClient.instance.api('list_users')
            .then(loadPeerListFromPacket));
      break;
      default:

        break;
    }
  });

  void tryConnect () {
    Model.PBXClient.instance.connect(config.eslHostname, config.eslPort).catchError((error, stackTrace) {
      if (error is SocketException) {
        logger.errorContext('ESL Connection failed - reconnecting in ${period.inSeconds} seconds', context);
        new Timer(period, tryConnect);

      } else {
        logger.errorContext('${error} : ${stackTrace != null ? stackTrace : ''}', context);
      }
    }).then ((_) => logger.infoContext('Connected to ${config.eslHostname}:${config.eslPort}', context));
  }

  tryConnect ();
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser..addFlag('help', abbr: 'h', help: 'Output this help')
        ..addOption('configfile', help: 'The JSON configuration file. Defaults to config.json')
        ..addOption('httpport', help: 'The port the HTTP server listens on.  Defaults to ${Default.httpport}')
        ..addOption('servertoken', help: 'servertoken');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];

void loadPeerListFromPacket (ESL.Response response) {
  Model.PeerList.instance = new ESL.PeerList.fromMultilineBuffer(response.rawBody);
}