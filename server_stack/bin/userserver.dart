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

library openreception.server.user;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:openreception.framework/filestore.dart' as filestore;
import 'package:openreception.framework/service-io.dart' as service;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/controller/controller-agent_statistics.dart'
    as controller;
import 'package:openreception.server/controller/controller-client_notifier.dart'
    as controller;
import 'package:openreception.server/controller/controller-user.dart'
    as controller;
import 'package:openreception.server/controller/controller-user_state.dart'
    as controller;
import 'package:openreception.server/model.dart' as model;
import 'package:openreception.server/router/router-user.dart' as router;

Future main(List<String> args) async {
  ///Init logging. Inherit standard values.
  Logger.root.level = config.userServer.log.level;
  Logger.root.onRecord.listen(config.userServer.log.onRecord);

  Logger log = new Logger('UserServer');

  final ArgParser parser = new ArgParser()
    ..addFlag('help', help: 'Output this help', negatable: false)
    ..addOption('filestore', abbr: 'f', help: 'Path to the filestore backend')
    ..addOption('httpport',
        abbr: 'p',
        defaultsTo: config.userServer.httpPort.toString(),
        help: 'The port the HTTP server listens on.')
    ..addOption('host',
        abbr: 'h',
        defaultsTo: config.userServer.externalHostName,
        help: 'The hostname or IP listen-address for the HTTP server')
    ..addOption('auth-uri',
        defaultsTo: config.authServer.externalUri.toString(),
        help: 'The uri of the authentication server')
    ..addOption('notification-uri',
        defaultsTo: config.notificationServer.externalUri.toString(),
        help: 'The uri of the notification server');

  final ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  if (parsedArgs['filestore'] == null) {
    print('Filestore path is required');
    print(parser.usage);
    exit(1);
  }

  final service.Authentication _authService = new service.Authentication(
      Uri.parse(parsedArgs['auth-uri']),
      config.userServer.serverToken,
      new service.Client());

  final service.NotificationService _notification =
      new service.NotificationService(Uri.parse(parsedArgs['notification-uri']),
          config.userServer.serverToken, new service.Client());

  final filestore.User _userStore = new filestore.User(
      parsedArgs['filestore'] + '/user',
      new filestore.GitEngine(parsedArgs['filestore'] + '/user'));

  final model.AgentHistory agentHistory = new model.AgentHistory();
  final model.UserStatusList userStatus = new model.UserStatusList();

  final _userController =
      new controller.User(_userStore, _notification, _authService);
  final _statsController = new controller.AgentStatistics(agentHistory);
  final _userStateController =
      new controller.UserState(agentHistory, userStatus);

  /// Client notification controller.
  final controller.ClientNotifier notifier =
      new controller.ClientNotifier(_notification);
  notifier.userStateSubscribe(userStatus);

  await (new router.User(_authService, _notification, _userController,
          _statsController, _userStateController))
      .listen(
          hostname: parsedArgs['host'],
          port: int.parse(parsedArgs['httpport']));
  log.info('Ready to handle requests');
}
