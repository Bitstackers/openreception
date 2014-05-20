import 'dart:io';
import 'dart:convert';
import 'dart:convert' show UTF8;

void main() {

  Map<String, Map> Servers = {
    'MiscServer': {
      'path': 'MiscServer/bin/miscserver.dart'
    },
//    'CallFlowWrapper': {
//      'path': 'CallFlowControl/bin/callflowcontrol.dart'
//    },
    'AuthServer': {
      'path': 'AuthServer/bin/authserver.dart'
    },
    'ContactServer': {
      'path': 'ContactServer/bin/contactserver.dart'
    },
    'LogServer': {
      'path': 'LogServer/bin/logserver.dart'
    },
    'MessageServer': {
      'path': 'MessageServer/bin/messageserver.dart'
    },
    'MessageDispatcher': {
      'path': 'MessageDispatcher/bin/messagedispacher.dart'
    },
    'NotificationServer': {
      'path': 'NotificationServer/bin/notificationserver.dart'
    },
    'ReceptionServer': {
      'path': 'ReceptionServer/bin/receptionserver.dart'
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
      (server['process'] as Process).kill(ProcessSignal.SIGINT);
    });
    exit(0);
  });
  
  Servers.forEach((String serverName, Map server) {
    print('Starting ${serverName}..');
    Process.start('dart', [server['path']]).then((process) {
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
