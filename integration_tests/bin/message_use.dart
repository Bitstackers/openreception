//import 'dart:async';

import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/storage.dart'    as Storage;
import 'package:openreception_framework/service.dart'    as Service;
//import '../lib/service-io.dart' as ServiceIO;
import 'package:openreception_framework/service-html.dart' as ServiceHTML;

import 'package:logging/logging.dart';


void main() {

  Logger.root.onRecord.listen(print);
  Logger.root.level = Level.ALL;


  print ("READY!!");

  ServiceHTML.Client client = new ServiceHTML.Client();

  print (client.toString());


  Storage.Message store = new Service.RESTMessageStore
      (Uri.parse('http://localhost:4040'),
       'feedabbadeadbeef0',
       new ServiceHTML.Client());

  store.get(1).then((Model.Message msg) {
      print ("Done getting");
      print (msg.asMap);
  }).catchError(print);

  store.list().then(print);

}
