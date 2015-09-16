import '../lib/or_test_fw.dart';

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:junitconfiguration/junitconfiguration.dart';

void main() {
  //TODO: redirect every log entry to a file.
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord record) =>
      logMessage(record.toString()));
  JUnitConfiguration.install();

  SupportTools st;

  /*
   * We treat the test framework as a test itself. This gives us the
   * possibility to output the test state, and to wait for setup and teardown.
   */
  group ('TestFramework', () {

    setUp (() {
      return SupportTools.instance.then((SupportTools init) => st = init);
    });

    test ('Setup', () {
      expect(st, isNotNull);
      expect(st.customers, isNotEmpty);
      expect(st.peerMap, isNotEmpty);
      expect(st.receptionists, isNotEmpty);
      expect(st.tokenMap, isNotEmpty);
      expect(st.tokenMap, isNotEmpty);
    });
  });

  runAuthServerTests();
  runBenchmarkTests();
  runCalendarTests ();
  runConfigServerTests();
  runContactTests();
  runCallFlowTests();
  runUserTests();
  runMessageTests();
  runNotificationTests();
  runOrganizationTests();

  runAllTests();
  runReceptionTests();
  //runUseCaseTests();

  group ('TestFramework', () {
    tearDown (() {
      return SupportTools.instance.then((SupportTools st) => st.tearDown());
    });

    test ('Teardown', () => true);

  });
}
