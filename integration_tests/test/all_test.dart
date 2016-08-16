library openreception_tests;

import 'package:openreception_tests/filestore.dart' as filestore;
import 'package:openreception_tests/rest.dart' as rest;
import 'package:openreception_tests/benchmark.dart' as benchmark;

import 'package:openreception_tests/support.dart';

import 'package:logging/logging.dart';
import 'package:test/test.dart';

void runBenchmarkTests() {
  benchmark.allTests();
}

void runFilestoreTests() {
  filestore.allTests();
}

void runRestStoreTests() {
  rest.allTests();
}

void main() {
  void logMessage(LogRecord record) {
    final String error = '${record.error != null
        ? ' - ${record.error}'
        : ''}'
        '${record.stackTrace != null
          ? ' - ${record.stackTrace}'
          : ''}';

    if (record.level.value > Level.INFO.value) {
      print('${record.time} - ${record}$error');
    } else {
      print('${record.time} - ${record}$error');
    }
  }

  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen(logMessage);

  /*
   * We treat the test framework as a test itself. This gives us the
   * possibility to output the test state, and to wait for setup and teardown.
   */
  group('pre-test setup', () {
    Logger _log = new Logger('test environment detection');
    TestEnvironmentConfig envConfig;

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
