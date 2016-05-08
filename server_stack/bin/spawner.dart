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

library openreception.server.spawner;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

const bool checked = false;
const bool useObservatory = false;

Random rand = new Random();
const int maxRandomInt = (1 << 32) - 1;

void main(List<String> arguments) {
  String serverTokenDir = '/tmp/tokens${rand.nextInt(maxRandomInt)}';
  String fileStoreDir = '/tmp/z5svC3';

  if (arguments.length > 0) {
    serverTokenDir = arguments[0];
  }
  if (arguments.length > 1) {
    fileStoreDir = arguments[1];
  }
  //Directory tmpStore = new Directory('/tmp').createTempSync();
  Directory tmpStore = new Directory(fileStoreDir);

  Directory dir = new Directory(serverTokenDir);
  dir.createSync();
  String serverTokenDirAbsolutPath = dir.absolute.path;

  Map<String, Map> servers = {
    'AuthServer': {
      'path': 'bin/authserver.dart',
      'args': [
        '--servertokendir',
        '$serverTokenDirAbsolutPath',
        '-f' + tmpStore.path
      ]
    },
    'CalendarServer': {
      'path': 'bin/calendarserver.dart',
      'args': ['-f' + tmpStore.path]
    },
    'CallFlow': {'path': 'bin/callflowcontrol.dart', 'args': []},
    'DialplanServer': {
      'path': 'bin/dialplanserver.dart',
      'args': ['-f' + tmpStore.path]
    },
    'CDRServer': {
      'path': 'bin/cdrserver.dart',
      'args': ['-f' + tmpStore.path]
    },
    'ContactServer': {
      'path': 'bin/contactserver.dart',
      'args': ['-f' + tmpStore.path]
    },
    'MessageServer': {
      'path': 'bin/messageserver.dart',
      'args': ['-f' + tmpStore.path]
    },
    'MessageDispatcher': {
      'path': 'bin/messagedispatcher.dart',
      'args': ['-f' + tmpStore.path]
    },
    'ConfigServer': {'path': 'bin/configserver.dart', 'args': []},
    'NotificationServer': {
      'path': 'bin/notificationserver.dart',
      'args': ['-f' + tmpStore.path]
    },
    'ReceptionServer': {
      'path': 'bin/receptionserver.dart',
      'args': ['-f' + tmpStore.path]
    },
    'UserServer': {
      'path': 'bin/userserver.dart',
      'args': ['-f' + tmpStore.path]
    }
  };

  ProcessSignal.SIGINT.watch().listen((_) {
    servers.forEach((String serverName, Map server) {
      print('Sending SIGINT to instance of ${serverName}');
      (server['process'] as Process).kill(ProcessSignal.SIGINT);
    });
    exit(0);
  });

  ProcessSignal.SIGTERM.watch().listen((_) {
    servers.forEach((String serverName, Map server) {
      print('Sending SIGTERM to instance of ${serverName}');
      (server['process'] as Process).kill(ProcessSignal.SIGTERM);
    });
    exit(0);
  });

  int opservatoryCount = 8182;

  servers.forEach((String serverName, Map server) {
    print('Starting ${serverName}..');

    List<String> args = checked ? ['--checked'] : [];
    if (useObservatory) {
      args.addAll(['--enable-vm-service=${opservatoryCount++}']);
    }

    args.add(server['path']);
    args.addAll(server['args'] as Iterable<String>);

    Process.start('dart', args).then((process) {
      server['process'] = process;

      process.stdout
          .transform(UTF8.decoder)
          .transform(new LineSplitter())
          .listen((String line) {
        print('${serverName} (output): ${line}');
      });
      process.stderr
          .transform(UTF8.decoder)
          .transform(new LineSplitter())
          .listen((String line) {
        print('${serverName} (errors): ${line}');
      });
    });
  });
}
