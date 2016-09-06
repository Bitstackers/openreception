/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:orf/filestore.dart' as filestore;
import 'package:openreception_framework/model.dart' as old_or_model;
import 'package:openreception_framework/service-io.dart' as old_or_service;
import 'package:openreception_framework/service.dart' as old_or_service;
import 'package:or_migrate/or_migrate.dart' as or_migrate;

Future main(List<String> arguments) async {
  Stopwatch timer = new Stopwatch()..start();
  Logger _log = new Logger('or_migrate');
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(_printLog);

  final ArgParser argParser = new ArgParser()
    ..addOption('config-server',
        help: 'The URI of the config server of the '
            'openreception stack to migrate from.')
    ..addOption('token',
        help: 'A valid authentication token. Get one from '
            'The management client or receptionist client.')
    ..addOption('output-dir',
        help: 'The directory to create the new filestore in. If not provided, '
            'a new datastore will be created in temporary folder.');

  final ArgResults result = argParser.parse(arguments);
  final String configUriString = result['config-server'];

  final String token = result['token'];
  final String outputPath = result['output-dir'];

  /// Input validation
  if (configUriString == null) {
    _exit('Config URI must not be empty.\n\n' + argParser.usage);
  } else if (token == null) {
    _exit('Token must not be empty.\n\n' + argParser.usage);
  }

  final old_or_service.Client transport = new old_or_service.Client();

  final Directory storeDir = outputPath == null
      ? Directory.systemTemp.createTempSync()
      : new Directory(outputPath);

  if (!storeDir.existsSync()) {
    _log.info('Creating directory ${storeDir.path}.');
    storeDir.createSync();
  } else {
    if (storeDir.listSync().isNotEmpty) {
      _exit(
          '${storeDir.path} is not empty. Please supply a path to a non-empty '
          'folder, or omit the \'output-dir\' option.');
    }
  }

  final old_or_model.ClientConfiguration clientConfig =
      (await new old_or_service.RESTConfiguration(
              Uri.parse(configUriString), transport)
          .clientConfig());
  final datastore = new filestore.DataStore(storeDir.path);

  final or_migrate.MigrationEnvironment migrationEnvironment =
      new or_migrate.MigrationEnvironment(
          datastore,
          new old_or_service.RESTOrganizationStore(
              clientConfig.receptionServerUri, token, transport),
          new old_or_service.RESTReceptionStore(
              clientConfig.receptionServerUri, token, transport),
          new old_or_service.RESTContactStore(
              clientConfig.contactServerUri, token, transport),
          new old_or_service.RESTUserStore(
              clientConfig.userServerUri, token, transport),
          new old_or_service.RESTEndpointStore(
              clientConfig.contactServerUri, token, transport),
          new old_or_service.RESTIvrStore(
              clientConfig.dialplanServerUri, token, transport),
          new old_or_service.RESTDialplanStore(
              clientConfig.dialplanServerUri, token, transport),
          new old_or_service.RESTCalendarStore(
              clientConfig.calendarServerUri, token, transport),
          new old_or_service.RESTMessageStore(
              clientConfig.messageServerUri, token, transport));

  await migrationEnvironment.importReceptions();
  await migrationEnvironment.importBaseContacts();
  await migrationEnvironment.importOrganizations();
  await migrationEnvironment.importUsers();
  await migrationEnvironment.importDialplans();
  await migrationEnvironment.importIvrs();

  await migrationEnvironment.importMessages();
  await migrationEnvironment.importReceptionAttributes();
  await migrationEnvironment.importCalendarEntries();

  await migrationEnvironment.validateUsers();
  transport.client.close(force: true);

  print('Import took ${timer.elapsedMilliseconds}ms');
}

/**
 * Exit the application abnormally (non-zero return value) and
 * print [message] to stdout.
 */
void _exit(String message) {
  print(message);
  exit(1);
}

/**
 * Pronts stuff using print. Pront is a different, but very made-up, word
 * for print.
 */
void pront(stuff) => print(stuff);

/**
 * Log record handler.
 */
void _printLog(LogRecord l) {
  StringBuffer output =
      new StringBuffer('[${l.level.name}] ${l.loggerName}: ${l.message}');

  if (l.error != null) {
    output.write('error: ${l.error}');
  }
  if (l.stackTrace != null) {
    print(l.stackTrace);
  }

  if (l.level > Level.INFO) {
    stderr.writeln(output.toString());
  } else {
    stdout.writeln(output.toString());
  }
}
