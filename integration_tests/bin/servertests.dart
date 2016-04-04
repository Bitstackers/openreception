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

  /*
   * We treat the test framework as a test itself. This gives us the
   * possibility to output the test state, and to wait for setup and teardown.
   */
  group('pre-test setup', () {
    TestEnvironmentConfig envConfig;
    Logger _log = new Logger('test environment detection');

    setUp(() async {
      envConfig = new TestEnvironment().envConfig;
      await envConfig.load();
    });

    test('Setup', () {
      expect(envConfig, isNotNull);
      expect(envConfig.externalIp, isNotEmpty);
      _log.info(envConfig.toString());
    });
  });

  runFilestoreTests();
  runRestStoreTests();
  runBenchmarkTests();

  /* We treat the test framework as a test itself. This gives us the
   * possibility to output the test state, and to wait for setup and teardown.
   */
  group('post-test cleanup', () {
    test('finalize test environment', () => new TestEnvironment().finalize());
  });
}
