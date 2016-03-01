library openreception_tests.rest;

import 'dart:async';

import 'package:openreception_tests/storage.dart' as storeTest;
import 'package:openreception_tests/support.dart';
import 'package:openreception_tests/process.dart' as process;
import 'package:openreception_tests/config.dart';

import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-io.dart' as transport;
import 'package:unittest/unittest.dart';

// part 'rest/rest-calendar.dart';
// part 'rest/rest-contact.dart';
// part 'rest/rest-dialplan.dart';
// part 'rest/rest-ivr.dart';
part 'rest/rest-organization.dart';
part 'rest/rest-reception.dart';

const String _namespace = 'rest';
/**
 * Run all filestore tests.
 */
runAllRestStoreTests() {
  _runReceptionTests();
  // _runCalendarTests();
  // _runContactTests();
  // _runDialplanTests();
  // _runIvrTests();
  _runOrganizationTests();
}
