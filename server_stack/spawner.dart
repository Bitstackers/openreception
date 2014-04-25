import 'dart:io';
import 'dart:convert';
import 'dart:convert' show UTF8;

void main() {
  
  Map<String,Map> Servers = {'MiscServer'         : {'path' : 'MiscServer/bin/miscserver.dart'},
                             'AuthServer'         : {'path' : 'AuthServer/bin/authserver.dart'},
                             'ContactServer'      : {'path' : 'ContactServer/bin/contactserver.dart'},
                             'LogServer'          : {'path' : 'LogServer/bin/logserver.dart'},
                             'CDRServer'          : {'path' : 'CDRServer/bin/cdrserver.dart'},
                             'MessageDispatcher'  : {'path' : 'MessageDispatcher/bin/messagedispacher.dart'},
                             'MessageServer'      : {'path' : 'MessageServer/bin/messageserver.dart'},
                             'NotificationServer' : {'path' : 'NotificationServer/bin/notificationserver.dart'},
//                             'OrganizationServer' : {'path' : 'MessageServer/bin/messageserver.dart'},
                             'ReceptionServer'    : {'path' : 'ReceptionServer/bin/receptionserver.dart'},
                             'UserServer'         : {'path' : 'UserServer/bin/userserver.dart'}};
  
  Servers.forEach((String serverName, Map server) {
    print ('Starting ${serverName}..');
    Process.start('dart', [server['path']]).then((process) {
        process.stdout
        .transform(UTF8.decoder)
        .transform(new LineSplitter())
        .listen(
          (String line) {
            print('${serverName}: ${line}');
          });
        process.stderr
        .transform(UTF8.decoder)
        .transform(new LineSplitter())
        .listen(
          (String line) {
            print('${serverName}: ${line}');
          });
    });
  });
}