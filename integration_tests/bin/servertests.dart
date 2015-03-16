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

  group ('TestFramework', () {

    tearDown (() {
      return SupportTools.instance;
    });

    test ('Setup', () => true);

  });

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

  group ('service.Reception', () {
    test ('CORS headers present', Reception_Store.isCORSHeadersPresent);
    test ('Non-existing path', Reception_Store.nonExistingPath);
    test ('Non-existing reception', Reception_Store.nonExistingReception);
    test ('Existing reception', Reception_Store.existingReception);
    test ('Calendar listing', Reception_Store.existingReceptionCalendar);
    test ('Calendar creation', Reception_Store.calendarEventCreate);
    test ('Calendar update', Reception_Store.calendarEventUpdate);
    test ('Calendar single', Reception_Store.calendarEventExisting);
    test ('Calendar single (non-existing)',
        Reception_Store.calendarEventNonExisting);
  });

  group ('TestFramework', () {
    tearDown (() {
      return SupportTools.instance.then((SupportTools st) => st.tearDown());
    });

    test ('Teardown', () => true);

  });
}
