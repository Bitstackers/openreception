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

library ors.contact;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:orf/filestore.dart' as filestore;
import 'package:orf/gzip_cache.dart' as gzip_cache;
import 'package:orf/service-io.dart' as service;
import 'package:orf/service.dart' as service;
import 'package:ors/configuration.dart';
import 'package:ors/controller/controller-contact.dart' as controller;
import 'package:ors/router/router-contact.dart' as router;

Logger _log = new Logger('ContactServer');
ArgResults _parsedArgs;
ArgParser _parser = new ArgParser();

/**
 * The OR-Stack contact server. Provides a REST interface for retrieving and
 * manipulating contacts.
 */
Future main(List<String> args) async {
  ///Init logging.
  Logger.root.level = config.contactServer.log.level;
  Logger.root.onRecord.listen(config.contactServer.log.onRecord);

  ///Handle argument parsing.
  final ArgParser parser = new ArgParser()
    ..addFlag('help', help: 'Output this help', negatable: false)
    ..addOption('filestore', abbr: 'f', help: 'Path to the filestore backend')
    ..addOption('httpport',
        abbr: 'p',
        defaultsTo: config.contactServer.httpPort.toString(),
        help: 'The port the HTTP server listens on.')
    ..addOption('host',
        abbr: 'h',
        defaultsTo: config.contactServer.externalHostName,
        help: 'The hostname or IP listen-address for the HTTP server')
    ..addOption('auth-uri',
        defaultsTo: config.authServer.externalUri.toString(),
        help: 'The uri of the authentication server')
    ..addOption('notification-uri',
        defaultsTo: config.notificationServer.externalUri.toString(),
        help: 'The uri of the notification server')
    ..addFlag('experimental-revisioning',
        defaultsTo: false,
        help: 'Enable or disable experimental Git revisioning on this server');

  final ArgResults parsedArgs = parser.parse(args);

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

  int port;
  try {
    port = int.parse(parsedArgs['httpport']);
    if (port < 1 || port > 65535) {
      throw new FormatException();
    }
  } on FormatException {
    stderr.writeln('Bad port argument: ${parsedArgs['httpport']}');
    print('');
    print(parser.usage);
    exit(1);
  }

  final bool revisioning = parsedArgs['experimental-revisioning'];

  final revisionEngine = revisioning
      ? new filestore.GitEngine(parsedArgs['filestore'] + '/contact')
      : null;

  final service.Authentication _authentication = new service.Authentication(
      Uri.parse(parsedArgs['auth-uri']),
      config.userServer.serverToken,
      new service.Client());

  final service.NotificationService _notification =
      new service.NotificationService(Uri.parse(parsedArgs['notification-uri']),
          config.userServer.serverToken, new service.Client());

  final Uri notificationUri =
      Uri.parse('ws://${_notification.host.host}:${_notification.host.port}'
          '/notifications?token=${config.contactServer.serverToken}');

  final service.WebSocket wsClient =
      await (new service.WebSocketClient()).connect(notificationUri);

  final service.NotificationSocket _notificationSocket =
      new service.NotificationSocket(wsClient);

  final filestore.Reception rStore =
      new filestore.Reception(filepath + '/reception');

  final filestore.Contact cStore =
      new filestore.Contact(rStore, filepath + '/contact', revisionEngine);

  final _cache = new gzip_cache.ContactCache(
      cStore,
      cStore.onContactChange,
      cStore.onReceptionDataChange,
      _notificationSocket.onReceptionChange,
      _notificationSocket.onOrganizationChange);

  await _prefillCache(_cache);

  controller.Contact contactController =
      new controller.Contact(cStore, _notification, _authentication, _cache);

  final router.Contact contactRouter =
      new router.Contact(_authentication, _notification, contactController);

  await contactRouter.listen(port: port, hostname: parsedArgs['host']);

  _log.info('Ready to handle requests');
}

Future<Null> _prefillCache(gzip_cache.ContactCache _cache) async {
  Stopwatch timer = new Stopwatch()..start();
  _log.info('Prefilling cache');
  await _cache.prefill();

  int byteCount =
      _cache.stats['contactSize'] + _cache.stats['receptionContactSize'];
  timer.stop();
  _log.info('Prefilled cache with ${byteCount~/1024}kB gzipped data '
      'in ${timer.elapsedMilliseconds}ms.');
}
