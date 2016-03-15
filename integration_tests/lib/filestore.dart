library openreception_tests.filestore;

import 'package:openreception_tests/storage.dart' as storeTest;
import 'package:openreception_tests/support.dart';

import 'package:openreception_framework/model.dart' as model;
import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';

part 'filestore/filestore-calendar.dart';
part 'filestore/filestore-contact.dart';
part 'filestore/filestore-dialplan.dart';
part 'filestore/filestore-ivr.dart';
part 'filestore/filestore-message_queue.dart';
part 'filestore/filestore-message.dart';
part 'filestore/filestore-organization.dart';
part 'filestore/filestore-reception.dart';
part 'filestore/filestore-user.dart';

const String _namespace = 'filestore';
/**
 * Run all filestore tests.
 */
allTests() {
  _runReceptionTests();
  _runCalendarTests();
  _runContactTests();
  _runDialplanTests();
  _runIvrTests();
  _runOrganizationTests();
  _runUserTests();
  _runMessageTests();
  _runMessageQueueTests();
}
