library spawner;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

const bool CHECKED = true;

Random rand = new Random();
const int MAX_RANDOM_INT = (1<<32)-1;

void main(List<String> arguments) {
  List<String> tokens = new List(5).map((_) => generateToken()).toList(growable: false);
  int index = 0;
  String ServerTokenDir = '/tmp/tokens${rand.nextInt(MAX_RANDOM_INT)}';

  if(arguments.length > 0) {
    ServerTokenDir = arguments[0];
  }

  Directory dir = new Directory(ServerTokenDir);
  dir.createSync();
  String serverTokenDirAbsolutPath = dir.absolute.path;

  Map<String, Map> Servers = {
    'AuthServer': {
      'path': 'AuthServer/bin/authserver.dart',
      'args': ['--servertokendir', '$serverTokenDirAbsolutPath']
    },
    'CallFlow': {
      'path': 'CallFlowControl/bin/callflowcontrol.dart',
      'args': ['--servertoken', tokens[index++]]
    },
    'CDRServer': {
      'path': 'CDRServer/bin/cdrserver.dart',
      'args': []
    },
    'ContactServer': {
      'path': 'ContactServer/bin/contactserver.dart',
      'args': ['--servertoken', tokens[index++]]
    },
    'LogServer': {
      'path': 'LogServer/bin/logserver.dart',
      'args': []
    },
    'ManagementServer': {
      'path': 'ManagementServer/bin/server.dart',
      'args': ['--servertoken', tokens[index++]]
    },
/*    'MessageServer': {
      'path': 'MessageServer/bin/messageserver.dart',
      'args': ['--servertoken', tokens[index++]]
    },*/
    'MessageDispatcher': {
      'path': 'MessageDispatcher/bin/messagedispacher.dart',
      'args': []
    },
    'MiscServer': {
      'path': 'MiscServer/bin/miscserver.dart',
      'args': []
    },
    'NotificationServer': {
      'path': 'NotificationServer/bin/notificationserver.dart',
      'args': []
    },
    'ReceptionServer': {
      'path': 'ReceptionServer/bin/receptionserver.dart',
      'args': ['--servertoken', tokens[index++]]
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

  writeTokensToDisk(tokens, serverTokenDirAbsolutPath).then((_) =>
  Servers.forEach((String serverName, Map server) {
    print('Starting ${serverName}..');

    List<String> args = CHECKED ? ['--checked'] : [];
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
  }));

}

Future writeTokensToDisk(List<String> tokens, String dir) {
  tokens.forEach(print);
  Map content =
    {"access_token":"none",
     "expires_in":3600,
     "id_token":"none",
     "expiresAt":"2042-12-31 00:00:00.000",
     "identity":{
       "name":"ServerToken",
       "groups":["Receptionist","Administrator","Service agent"],
       "identities":[],"remote_attributes":{}}};

  return Future.forEach(tokens, (String token) {
    File file = new File('${dir}/${token}.servertoken');
    return file.writeAsString(JSON.encode(content));
  });
}

String generateToken() {

  List<int> shaContent = new List<int>();
  for(int i = 0; i < 100000; i++) {
    shaContent.add(rand.nextInt(MAX_RANDOM_INT));
  }

  SHA256 sha = new SHA256()
    ..add(shaContent);
  return CryptoUtils.bytesToHex(sha.close());
}
