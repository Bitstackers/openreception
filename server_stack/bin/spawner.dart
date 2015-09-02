library spawner;

import 'dart:io';
import 'dart:convert';
import 'dart:math';

const bool CHECKED = false;
const bool USE_OBSERVATORY = false;

Random rand = new Random();
const int MAX_RANDOM_INT = (1<<32)-1;

void main(List<String> arguments) {
  String ServerTokenDir = '/tmp/tokens${rand.nextInt(MAX_RANDOM_INT)}';

  if(arguments.length > 0) {
    ServerTokenDir = arguments[0];
  }

  Directory dir = new Directory(ServerTokenDir);
  dir.createSync();
  String serverTokenDirAbsolutPath = dir.absolute.path;

  Map<String, Map> Servers = {
    'AuthServer': {
      'path': 'bin/authserver.dart',
      'args': ['--servertokendir', '$serverTokenDirAbsolutPath']
    },
    'CallFlow': {
      'path': 'bin/callflowcontrol.dart',
      'args': []
    },
    'CDRServer': {
      'path': 'bin/cdrserver.dart',
      'args': []
    },
    'ContactServer': {
      'path': 'bin/contactserver.dart',
      'args': []
    },
    'ManagementServer': {
      'path': 'bin/managementserver.dart',
      'args': []
    },
    'MessageServer': {
      'path': 'bin/messageserver.dart',
      'args': []
    },
    'MessageDispatcher': {
      'path': 'bin/messagedispatcher.dart',
      'args': []
    },
    'MiscServer': {
      'path': 'bin/configserver.dart',
      'args': []
    },
    'NotificationServer': {
      'path': 'bin/notificationserver.dart',
      'args': []
    },
    'ReceptionServer': {
      'path': 'bin/receptionserver.dart',
      'args': []
    },
    'UserServer': {
      'path': 'bin/userserver.dart',
      'args' : []
    }
  };

  ProcessSignal.SIGINT.watch().listen((_) {
    Servers.forEach((String serverName, Map server) {
      print('Sending SIGINT to instance of ${serverName}');
      (server['process'] as Process).kill(ProcessSignal.SIGINT);
    });
    exit(0);
  });

  ProcessSignal.SIGTERM.watch().listen((_) {
    Servers.forEach((String serverName, Map server) {
      print('Sending SIGTERM to instance of ${serverName}');
      (server['process'] as Process).kill(ProcessSignal.SIGTERM);
    });
    exit(0);
  });

  int opservatoryCount = 8182;

  Servers.forEach((String serverName, Map server) {
    print('Starting ${serverName}..');

    List<String> args = CHECKED ? ['--checked'] : [];
    if(USE_OBSERVATORY) {
      args.add('--enable-vm-service=${opservatoryCount++}');
    }
    args.add(server['path']);
    args.addAll(server['args']);

    Process.start('dart', args).then((process) {
      server['process'] = process;

      process.stdout.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line) {
        print('${serverName} (output): ${line}');
      });
      process.stderr.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line) {
        print('${serverName} (errors): ${line}');
      });
    });
  });

}
