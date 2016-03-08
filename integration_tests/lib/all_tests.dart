library openreception_tests;

import 'package:openreception_framework/model.dart' as model;

import 'package:openreception_tests/filestore.dart' as filestore;
import 'package:openreception_tests/rest.dart' as rest;
import 'package:openreception_tests/benchmark.dart' as benchmark;

void runBenchmarkTests() {
  benchmark.allTests();
}

void runFilestoreTests() {
  filestore.allTests();
}

void runRestStoreTests() {
  rest.allTests();
}
