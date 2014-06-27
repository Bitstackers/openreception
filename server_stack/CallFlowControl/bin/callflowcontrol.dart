import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:OpenReceptionFramework/common.dart';
import '../lib/configuration.dart';
import 'package:OpenReceptionFramework/httpserver.dart' as http;
import '../lib/router.dart' as router;
import '../lib/model/model.dart' as Model;
import 'package:esl/esl.dart' as ESL; 

ArgResults parsedArgs;
ArgParser parser = new ArgParser();

ESL.PeerList peerList = null;

void main(List<String> args) {
  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if (showHelp()) {
      print(parser.getUsage());
    } else {
      config = new Configuration(parsedArgs);
      config.whenLoaded()
        .then((_) => connectESLClient())
        .then((_) => http.start(config.httpport, router.registerHandlers))
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

void connectESLClient() {
  
  const String context = 'connectClient';
  
  Duration period = new Duration(seconds : 3);
  
  logger.infoContext('Connecting to ${config.eslHostname}:${config.eslPort}', context);
  Model.PBXClient.instance =  new ESL.Connection();
  
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

  Model.PBXClient.instance.connect(config.eslHostname, config.eslPort).catchError((error, stackTrace) {
    if (error is SocketException) {
      logger.errorContext('ESL Connection failed - reconnecting in ${period.inSeconds} seconds', context);
      new Timer(period, connectESLClient);
      
    } else {
      logger.errorContext('${error} : ${stackTrace != null ? stackTrace : ''}', context);  
    }
  });
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