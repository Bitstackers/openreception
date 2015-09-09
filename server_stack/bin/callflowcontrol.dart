import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../lib/callflowcontrol/configuration.dart' as json;
import '../lib/callflowcontrol/router.dart' as router;
import '../lib/callflowcontrol/model/model.dart' as Model;
import 'package:esl/esl.dart' as ESL;
import 'package:logging/logging.dart';
import '../lib/configuration.dart';

Logger log = new Logger ('CallFlowControl');
ArgResults parsedArgs;
ArgParser parser = new ArgParser();

void main(List<String> args) {

  ///Init logging. Inherit standard values.
  Logger.root.level = Configuration.callFlowControl.log.level;
  Logger.root.onRecord.listen(Configuration.callFlowControl.log.onRecord);

  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if (showHelp()) {
      print(parser.usage);
    } else {
      json.config = new json.Configuration(parsedArgs);
      json.config.whenLoaded()
        .then((_) => router.connectAuthService())
        .then((_) => router.connectNotificationService())
        .then((_) => router.startNotifier())
        .then((_) => connectESLClient())
        .then((_) => router.start(port : json.config.httpport))
        .catchError(log.shout);
    }
  } catch(error, stackTrace) {
    log.shout(error, stackTrace);
  }
}

void connectESLClient() {

  Duration period = new Duration(seconds : 3);

  log.info('Connecting to ${json.config.eslHostname}:${json.config.eslPort}');

  Model.PBXClient.instance = new ESL.Connection();

  Model.CallList.instance.subscribe(Model.PBXClient.instance.eventStream);

  //TODO: Channel-List subscriptions.
  Model.CallList.instance.subscribeChannelEvents(Model.ChannelList.event);

  Model.PBXClient.instance.eventStream
    .listen(Model.ChannelList.instance.handleEvent)
    .onDone(connectESLClient); // Reconnect

  Model.PeerList.subscribe(Model.PBXClient.instance.eventStream);

  /// Respond to server requests.
  Model.PBXClient.instance.requestStream.listen((ESL.Packet packet) {
    switch (packet.contentType) {
      case (ESL.ContentType.Auth_Request):
        log.info('Connected to ${json.config.eslHostname}:${json.config.eslPort}');
        Model.PBXClient.instance.authenticate(json.config.eslPassword)
          .then((_) => Model.PBXClient.instance.event
             (Model.PBXEvent.requiredSubscriptions,
                format : ESL.EventFormat.Json)
            ..catchError(log.shout))
          .then((_) => Model.PBXClient.instance.api('list_users')
            .then(loadPeerListFromPacket))
          .then((_) => Model.PBXClient.instance.api('show channels as json')
            .then(loadChannelListFromPacket));

      break;
      default:

        break;
    }
  });

  void tryConnect () {
    Model.PBXClient.instance.connect(json.config.eslHostname, json.config.eslPort).catchError((error, stackTrace) {
      if (error is SocketException) {
        log.severe('ESL Connection failed - reconnecting in ${period.inSeconds} seconds');
        new Timer(period, tryConnect);

      } else {
        log.severe('Failed to connect to FreeSWTICH.', error, stackTrace);
      }
    });
  }

  tryConnect ();
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser..addFlag('help', abbr: 'h', help: 'Output this help')
        ..addOption('configfile', help: 'The JSON configuration file. Defaults to config.json')
        ..addOption('httpport', help: 'The port the HTTP server listens on.  Defaults to ${json.Default.httpport}')
        ..addOption('servertoken', help: 'servertoken');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];

void loadPeerListFromPacket (ESL.Response response) {

  bool peerIsInAcceptedContext(ESL.Peer peer) =>
    Configuration.callFlowControl.peerContexts.contains(peer.context);

  ESL.PeerList loadedList = new ESL.PeerList.fromMultilineBuffer(response.rawBody);

  loadedList.where(peerIsInAcceptedContext).forEach((ESL.Peer peer) {
    Model.PeerList.instance.add(peer);
  });

  log.info('Loaded ${Model.PeerList.instance.length} of ${loadedList.length} '
           'peers from FreeSWITCH');
}

Future loadChannelListFromPacket (ESL.Response response) {
  Map responseBody = JSON.decode(response.rawBody);
  Iterable<String> channelUUIDs =
      responseBody.containsKey('rows')
      ? JSON.decode(response.rawBody)['rows'].map((Map m) => m['uuid'])
      : [];

  return Future.forEach(channelUUIDs, (String channelUUID) {
    return Model.PBXClient.instance.api('uuid_dump $channelUUID')
        .then((ESL.Response response) {

      List<String> lines = response.rawBody.split('\n');

      Map<String, String> fields= {};
      Map<String, dynamic> variables= {};

      lines.forEach((String line) {
        int splitIndex = line.indexOf(':');
        if (splitIndex > 0) {
          String key = line.substring(0, splitIndex).trim();
          String value = Uri.decodeFull(line.substring(splitIndex+1)).trim();

          if (key.startsWith("variable_")) {

            String keyNoPrefix = (key.split("variable_")[1]);
            variables[keyNoPrefix] = value;
          }
          fields[key] = value;

        }
        else {
          log.warning('Skipping bad buffer $line');
        }
      });

      Model.ChannelList.instance.update
        (new ESL.Channel.assemble(fields, variables));

    });

  })
  .then((_) {
    //TODO Reload call list based in the information in channel list.
    log.info('Loaded information about ${Model.ChannelList.instance.length} active channels into channel list');
  });

}