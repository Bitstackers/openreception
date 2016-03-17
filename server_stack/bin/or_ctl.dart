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

/**
 * The OR-Stack command-line control interface.
 */
library openreception.server.or_ctl;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import 'package:logging/logging.dart';
import 'package:openreception.server/configuration.dart';

//import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/service.dart' as service;
//import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/service-io.dart' as transport;

ArgResults parsedArgs;
ArgParser parser = new ArgParser();

Future main(List<String> args) async {
  ///Init logging.
  Logger.root.level = config.authServer.log.level;
  Logger.root.onRecord.listen(config.authServer.log.onRecord);

  ///Handle argument parsing.
  final ArgParser parser = new ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Output this help', negatable: false)
    ..addOption('deploy-dialplan')
    ..addOption('deploy-to')
    ..addOption('deploy-ivr');

  final ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  transport.Client client = new transport.Client();

  service.RESTDialplanStore rdpStore = new service.RESTDialplanStore(
      config.configserver.dialplanServerUri,
      config.dialplanserver.serverToken,
      client);

  service.RESTIvrStore ivrStore = new service.RESTIvrStore(
      config.configserver.dialplanServerUri,
      config.dialplanserver.serverToken,
      client);

  final String extension = parsedArgs['deploy-dialplan'];
  final String ivrMenu = parsedArgs['deploy-ivr'];
  final int rid = int.parse(parsedArgs['deploy-to']);

  if (extension != null) {
    await rdpStore.deployDialplan(extension, rid);
  }

  if (ivrMenu != null) {
    await ivrStore.deploy(ivrMenu);
  }

  client.client.close(force: true);
}
