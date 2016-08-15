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
import 'package:esl/constants.dart' as esl;
import 'package:esl/util.dart' as esl;

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

  _registerAndParseCommandlineArguments(args);

  if (_showHelp()) {
    print(parser.usage);
    exit(1);
  }

  final String hostname = parsedArgs['esl-hostname'];
  final String password = parsedArgs['esl-password'];
  final int port = int.parse(parsedArgs['esl-port']);

  await _connectApiClient(hostname, port, password);
  await _connectEventClient(hostname, port, password);

  await router.start(
      hostname: parsedArgs['host'],
      port: int.parse(parsedArgs['httpport']),
      authUri: Uri.parse(parsedArgs['auth-uri']),
      notificationUri: Uri.parse(parsedArgs['notification-uri']));
  log.info('Ready to handle requests');
}

/// Connect API client.
Future _connectApiClient(String hostname, int port, String password) async {
  Controller.PBX.apiClient = await _connectESLClient(hostname, port, password);

  Controller.PBX.apiClient.requestStream.listen((esl.Request request) async {
    if (request is esl.AuthRequest) {
      log.finest('Sending authentication');
      final esl.Reply reply =
          await Controller.PBX.apiClient.authenticate(password);

      if (!reply.isOk) {
        log.shout('ESL api Authentication failed - exiting');
        exit(1);
      } else {
        await Controller.PBX.loadPeers();
        await Controller.PBX.loadChannels();
        await Model.CallList.instance
            .reloadFromChannels(Model.ChannelList.instance);
      }
    }
  });
}

/// Connect API client.
Future _connectEventClient(String hostname, int port, String password) async {
  Controller.PBX.eventClient =
      await _connectESLClient(hostname, port, password);

  Model.CallList.instance.subscribe(Controller.PBX.eventClient.eventStream);

  Controller.PBX.eventClient.eventStream
      .listen(Model.ChannelList.instance.handleEvent);

  Controller.PBX.eventClient.eventStream
      .listen(Model.ActiveRecordings.instance.handleEvent);

  Controller.PBX.eventClient.eventStream.listen(Model.peerlist.handlePacket);

  /// Connect event client.
  Controller.PBX.eventClient.requestStream.listen((esl.Request request) async {
    if (request is esl.AuthRequest) {
      log.finest('Sending authentication');
      final esl.Reply reply =
          await Controller.PBX.eventClient.authenticate(password);

      if (!reply.isOk) {
        log.shout('ESL event Authentication failed - exiting');
        exit(1);
      } else {
        await Controller.PBX.eventClient
            .event(Model.PBXEvent.requiredSubscriptions,
                format: esl.EventFormat.json)
            .catchError(log.shout);
      }
    }
  });
}

Future<esl.Connection> _connectESLClient(
    String hostname, int port, String password) async {
  final Duration reconnectPeriod = new Duration(seconds: 3);

  Future<esl.Connection> tryConnect() async {
    log.info('Connecting to ${hostname}:${port}');

    try {
      final Socket socket = await Socket.connect(hostname, port);

      final esl.Connection connection =
          new esl.Connection(socket, onDisconnect: tryConnect);

      // Await a successful authentication.
      await esl.authHandler(connection, password);

      return connection;
    } on SocketException {
      log.severe('ESL Connection failed - reconnecting '
          'in ${reconnectPeriod.inSeconds} seconds');

      await new Future.delayed(reconnectPeriod);
      return tryConnect();
    } on AuthenticationException {
      log.severe('ESL Connection failed - reconnecting '
          'in ${reconnectPeriod.inSeconds} seconds');

      await new Future.delayed(reconnectPeriod);
      return tryConnect();
    }
  }

  return tryConnect();
}

void _registerAndParseCommandlineArguments(List<String> arguments) {
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

bool _showHelp() => parsedArgs['help'];
