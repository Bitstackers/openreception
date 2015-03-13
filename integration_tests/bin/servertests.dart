import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/service-io.dart' as Transport;
import 'package:openreception_framework/storage.dart' as Storage;

import '../lib/or_test_fw.dart';

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:junitconfiguration/junitconfiguration.dart';

import '../lib/config.dart';
import 'data/testdata.dart' as Test_Data;

void main() {
  //TODO: redirect every log entry to a file.
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord record) =>
      logMessage(record.toString()));
  JUnitConfiguration.install();

  runCallFlowTests();

  runAllTests();
  group('service.ResourceMessage', () {
    Storage.Message messageStore =
        new Service.RESTMessageStore(Config.messageServerUri,
            Config.serverToken, new Transport.Client());

   test('${Service.RESTMessageStore.className}.list (non-filtered)', () =>
       RESTMessageStore.messageList(messageStore));
   test('${Service.RESTMessageStore.className}.get (non-existing ID)', () =>
       RESTMessageStore.messageNotExists(messageStore));
   test('${Service.RESTMessageStore.className}.get (existence)', () =>
       RESTMessageStore.messageExists(messageStore, 1));
   test('${Service.RESTMessageStore.className}.get (equality)', () =>
       RESTMessageStore.messageMapEquality(messageStore, 1,
           new Model.Message.fromMap(Test_Data.testMessage_1_Map)));
  });
}
