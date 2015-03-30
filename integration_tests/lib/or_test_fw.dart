library or_test_fw;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' show Random;

import 'package:phonio/phonio.dart' as Phonio;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Transport;
import 'package:openreception_framework/storage.dart' as Storage;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/resource.dart' as Resource;
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'config.dart';
import 'data/testdata.dart' as Test_Data;

part 'support/customer.dart';
part 'support/customer_pool.dart';
part 'support/pool.dart';
part 'support/randomizer.dart';
part 'support/receptionist.dart';
part 'support/receptionist_pool.dart';
part 'support/support_tools.dart';

/// Authserver tests
part 'authserver/tests.dart';

/// Callflow server tests
part 'callflowcontrol/all_tests.dart';
part 'callflowcontrol/src/call_hangup.dart';
part 'callflowcontrol/src/call_list.dart';
part 'callflowcontrol/src/call_originate.dart';
part 'callflowcontrol/src/call_park.dart';
part 'callflowcontrol/src/call_pickup.dart';
part 'callflowcontrol/src/call_transfer.dart';
part 'callflowcontrol/src/peer.dart';

/// Contact store tests
part 'contact/src/contact_store.dart';
part 'contact/all_tests.dart';

/// Message store service tests
part 'messagestore/tests.dart';
part 'messagestore/src/rest_message_store.dart';

/// Data management service tests
part 'managementserver/all_tests.dart';
part 'managementserver/src/contact.dart';
part 'managementserver/src/organization.dart';
part 'managementserver/src/reception.dart';

/// Reception server tests
part 'reception/all_tests.dart';
part 'reception/src/reception_store.dart';

/// Use case tests
part 'use_case/all_tests.dart';
part 'use_case/src/uc-find_contact.dart';
part 'use_case/src/uc-forward_call.dart';
part 'use_case/src/uc-incoming_call.dart';
part 'use_case/src/uc-send_message.dart';

const String libraryName = 'Test';

