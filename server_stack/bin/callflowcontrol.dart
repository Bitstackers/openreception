/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.server.call_flow;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:esl/esl.dart' as esl;
import 'package:logging/logging.dart';
import 'package:openreception.server/callflowcontrol/controller.dart'
    as Controller;
import 'package:openreception.server/callflowcontrol/model/model.dart' as Model;
import 'package:openreception.server/callflowcontrol/router.dart' as router;
import 'package:openreception.server/configuration.dart';

Logger log = new Logger('callflow');
ArgResults parsedArgs;
ArgParser parser = new ArgParser();

class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException([this.message = ""]);

  String toString() => "NotFound: $message";
}

/**
 * TODO: Recover from text/disconnect.
 */
Future main(List<String> args) async {
  ///Init logging. Inherit standard values.
  Logger.root.level = config.callFlowControl.log.level;
  Logger.root.onRecord.listen(config.callFlowControl.log.onRecord);

  registerAndParseCommandlineArguments(args);

  if (showHelp()) {
    print(parser.usage);
  } else {
    connectESLClient();
    await router.start(
        hostname: parsedArgs['host'],
        port: int.parse(parsedArgs['httpport']),
        authUri: Uri.parse(parsedArgs['auth-uri']),
        notificationUri: Uri.parse(parsedArgs['notification-uri']));
    log.info('Ready to handle requests');
  }
}

void connectESLClient() {
  final Duration period = new Duration(seconds: 3);
  final String hostname = parsedArgs['esl-hostname'];
  final String password = parsedArgs['esl-password'];
  final int port = int.parse(parsedArgs['esl-port']);

  log.info('Connecting to ${hostname}:${port}');

  Controller.PBX.apiClient = new esl.Connection();
  Controller.PBX.eventClient = new esl.Connection();

  Model.CallList.instance.subscribe(Controller.PBX.eventClient.eventStream);

  Controller.PBX.eventClient.eventStream
      .listen(Model.ChannelList.instance.handleEvent)
      .onDone(connectESLClient); // Reconnect

  Controller.PBX.eventClient.eventStream
      .listen(Model.ActiveRecordings.instance.handleEvent);

  Controller.PBX.eventClient.eventStream.listen(Model.peerlist.handlePacket);

  Future authenticate(esl.Connection client) =>
      client.authenticate(password).then((esl.Reply reply) {
        if (reply.status != esl.Reply.OK) {
          log.shout('ESL Authentication failed - exiting');
          exit(1);
        }
      });

  /// Connect API client.
  Controller.PBX.apiClient.requestStream.listen((esl.Packet packet) async {
    switch (packet.contentType) {
      case (esl.ContentType.Auth_Request):
        log.info('Connected to ${hostname}:${port}');
        authenticate(Controller.PBX.apiClient)
            .then((_) => Controller.PBX.loadPeers())
            .then((_) => Controller.PBX.loadChannels().then((_) => Model
                .CallList.instance
                .reloadFromChannels(Model.ChannelList.instance)));

        break;

      default:
        break;
    }
  });

  /// Connect event client.
  Controller.PBX.eventClient.requestStream.listen((esl.Packet packet) {
    switch (packet.contentType) {
      case (esl.ContentType.Auth_Request):
        log.info('Connected to ${hostname}:${port}');
        authenticate(Controller.PBX.eventClient).then((_) => Controller
            .PBX.eventClient
            .event(Model.PBXEvent.requiredSubscriptions,
                format: esl.EventFormat.Json)..catchError(log.shout));

        break;

      default:
        break;
    }
  });

  Future tryConnect(esl.Connection client) async {
    await client.connect(hostname, port).catchError((error, stackTrace) {
      if (error is SocketException) {
        log.severe(
            'ESL Connection failed - reconnecting in ${period.inSeconds} seconds');
        new Timer(period, () => tryConnect(client));
      } else {
        log.severe('Failed to connect to FreeSWITCH.', error, stackTrace);
      }
    });
  }

  tryConnect(Controller.PBX.apiClient);
  tryConnect(Controller.PBX.eventClient);
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser
    ..addFlag('help', help: 'Output this help')
    ..addOption('httpport',
        defaultsTo: config.callFlowControl.httpPort.toString(),
        help: 'The port the HTTP server listens on.')
    ..addOption('host',
        abbr: 'h',
        defaultsTo: config.configserver.externalHostName,
        help: 'The hostname or IP listen-address for the HTTP server')
    ..addOption('esl-hostname',
        defaultsTo: config.callFlowControl.eslConfig.hostname,
        help: 'The hostname of the ESL server')
    ..addOption('esl-password',
        defaultsTo: config.callFlowControl.eslConfig.password,
        help: 'The password for the ESL server')
    ..addOption('esl-port',
        defaultsTo: config.callFlowControl.eslConfig.port.toString(),
        help: 'The port of the ESL server')
    ..addOption('auth-uri',
        defaultsTo: config.authServer.externalUri.toString(),
        help: 'The uri of the authentication server')
    ..addOption('notification-uri',
        defaultsTo: config.notificationServer.externalUri.toString(),
        help: 'The uri of the notification server');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
