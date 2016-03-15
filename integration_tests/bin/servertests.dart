import 'package:openreception_tests/support.dart';
import 'package:openreception_tests/all_tests.dart';

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:junitconfiguration/junitconfiguration.dart';

void main(List<String> arguments) {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord
      .listen((LogRecord record) => logMessage(record.toString()));

  if (!arguments.contains('--no-xml')) {
    JUnitConfiguration.install();
  }

  runFilestoreTests();
  runRestStoreTests();

  /* We treat the test framework as a test itself. This gives us the
   * possibility to output the test state, and to wait for setup and teardown.
   */
  group('post-test cleanup', () {
    test('finalize test environment', () => new TestEnvironment().finalize());
  });
}
