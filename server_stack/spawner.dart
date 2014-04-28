import 'dart:io';
import 'dart:convert';
import 'dart:convert' show UTF8;

void main() {
  
  Map<String,Map> Servers = {'MiscServer'         : {'path' : 'MiscServer/bin/miscserver.dart'},
                             'AuthServer'         : {'path' : 'AuthServer/bin/authserver.dart'},
                             'ContactServer'      : {'path' : 'ContactServer/bin/contactserver.dart'},
                             'LogServer'          : {'path' : 'LogServer/bin/logserver.dart'},
                             'MessageServer'      : {'path' : 'MessageServer/bin/messageserver.dart'},
                             'NotificationServer' : {'path' : 'NotificationServer/bin/notificationserver.dart'},
                             'ReceptionServer'    : {'path' : 'ReceptionServer/bin/receptionserver.dart'}};

  Servers.forEach((String serverName, Map server) {
    print ('Starting ${serverName}..');
    Process.start('dart', [server['path']]).then((process) {
        server['process'] = process;
        
        process.stdout
        .transform(UTF8.decoder)
        .transform(new LineSplitter())
        .listen(
          (String line) {
            print('${serverName} (output): ${line}');
          });
        process.stderr
        .transform(UTF8.decoder)
        .transform(new LineSplitter())
        .listen(
          (String line) {
            print('${serverName} (errors): ${line}');
          });
    });
  });
  
  ProcessSignal.SIGINT.watch().listen((_) {
    Servers.forEach((String serverName, Map server) {
      (server['process'] as Process).kill(ProcessSignal.SIGINT);
    });
  });
    
    ProcessSignal.SIGTERM.watch().listen((_) {
      Servers.forEach((String serverName, Map server) {
        (server['process'] as Process).kill(ProcessSignal.SIGINT);
      });
    });
}
