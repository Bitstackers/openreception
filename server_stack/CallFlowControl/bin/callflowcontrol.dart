import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../lib/configuration.dart';
import 'package:openreception_framework/httpserver.dart' as http;
import '../lib/router.dart' as router;
import '../lib/model/model.dart' as Model;
import 'package:esl/esl.dart' as ESL;
import 'package:logging/logging.dart';

Logger log = new Logger ('CallFlowControl')..onRecord.listen(print);
ArgResults parsedArgs;
ArgParser parser = new ArgParser();

void main(List<String> args) {
  Logger.root.level = Level.ALL;

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
        .catchError((e) => log.info('main() -> config.whenLoaded() ${e}'));
    }
  } on ArgumentError catch (e) {
    log.shout ('main() ArgumentError ${e}.');
    print(parser.usage);

  } on FormatException catch (e) {
    log.shout('main() FormatException ${e}');
    print(parser.usage);

  } catch (e) {
    log.shout('main() exception ${e}');
  }
}

void connectESLClient() {

  Duration period = new Duration(seconds : 3);

  log.info('Connecting to ${config.eslHostname}:${config.eslPort}');

  Model.PBXClient.instance = new ESL.Connection();

  Model.CallList.instance.subscribe(Model.PBXClient.instance.eventStream);

  //TODO: Channel-List subscriptions.
  Model.CallList.instance.subscribeChannelEvents(Model.ChannelList.event);

  Model.ChannelList.event.listen(print);

  Model.PBXClient.instance.eventStream.listen(Model.ChannelList.instance.handleEvent);

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
        log.severe('ESL Connection failed - reconnecting in ${period.inSeconds} seconds');
        new Timer(period, tryConnect);

      } else {
        log.severe('Failed to connect to FreeSWTICH.', error, stackTrace);
      }
    }).then ((_) => log.info('Connected to ${config.eslHostname}:${config.eslPort}'));
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