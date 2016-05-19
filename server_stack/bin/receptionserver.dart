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

library openreception.server.reception;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:openreception.framework/filestore.dart' as filestore;
import 'package:openreception.framework/service-io.dart' as service;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/controller/controller-organization.dart'
    as controller;
import 'package:openreception.server/controller/controller-reception.dart'
    as controller;
import 'package:openreception.server/router/router-reception.dart' as router;

Future main(List<String> args) async {
  ///Init logging.
  final Logger log = new Logger('server.message');
  Logger.root.level = config.receptionServer.log.level;
  Logger.root.onRecord.listen(config.receptionServer.log.onRecord);

  ///Handle argument parsing.
  ArgParser parser = new ArgParser()
    ..addFlag('help', help: 'Output this help', negatable: false)
    ..addOption('filestore', abbr: 'f', help: 'Path to the filestore backend')
    ..addOption('httpport',
        abbr: 'p',
        defaultsTo: config.receptionServer.httpPort.toString(),
        help: 'The port the HTTP server listens on.')
    ..addOption('host',
        abbr: 'h',
        defaultsTo: config.receptionServer.externalHostName,
        help: 'The hostname or IP listen-address for the HTTP server')
    ..addOption('auth-uri',
        defaultsTo: config.authServer.externalUri.toString(),
        help: 'The uri of the authentication server')
    ..addOption('notification-uri',
        defaultsTo: config.notificationServer.externalUri.toString(),
        help: 'The uri of the notification server');

  ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  final String filepath = parsedArgs['filestore'];
  if (filepath == null || filepath.isEmpty) {
    stderr.writeln('Filestore path is required');
    print('');
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

  final filestore.Reception rStore = new filestore.Reception(
      filepath + '/reception',
      new filestore.GitEngine(filepath + '/reception'));
  final filestore.Contact cStore = new filestore.Contact(rStore,
      filepath + '/contact', new filestore.GitEngine(filepath + '/contact'));
  final filestore.Organization oStore = new filestore.Organization(
      cStore,
      rStore,
      filepath + '/organization',
      new filestore.GitEngine(filepath + '/organization'));

  final controller.Organization organization =
      new controller.Organization(oStore, _notification, _authService);

  controller.Reception reception =
      new controller.Reception(rStore, _notification, _authService);

  await (new router.Reception(
          _authService, _notification, reception, organization)
      .listen(
          hostname: parsedArgs['host'],
          port: int.parse(parsedArgs['httpport'])));
  log.info('Ready to handle requests');
}
