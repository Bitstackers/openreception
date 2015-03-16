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

/// Message store service tests
part 'messagestore/tests.dart';
part 'managementserver/tests.dart';

/// Authserver tests
//part 'reception/all_tests.dart';
part 'reception/src/reception_store.dart';

/// Use cases
part 'use_case/uc-find_contact.dart';
part 'use_case/uc-forward_call.dart';
part 'use_case/uc-incoming_call.dart';
part 'use_case/uc-send_message.dart';
const String libraryName = 'OpenReceptionTest';

