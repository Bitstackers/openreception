library or_test_fw;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' show Random;

import 'package:phonio/phonio.dart' as Phonio;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/database.dart' as Database;
import 'package:openreception_framework/service-io.dart' as Transport;
import 'package:openreception_framework/storage.dart' as Storage;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/event.dart' as Event;
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
part 'service/src/service-auth.dart';
part 'service/authserver.dart';

/// Benchmark tests
part 'benchmark/src/tests.dart';
part 'benchmark/all_tests.dart';

/// Callflow server tests
part 'callflowcontrol/all_tests.dart';
part 'callflowcontrol/src/active_recording.dart';
part 'callflowcontrol/src/call_hangup.dart';
part 'callflowcontrol/src/call_list.dart';
part 'callflowcontrol/src/call_originate.dart';
part 'callflowcontrol/src/call_park.dart';
part 'callflowcontrol/src/call_pickup.dart';
part 'callflowcontrol/src/call_transfer.dart';
part 'callflowcontrol/src/peer.dart';
part 'callflowcontrol/src/state_reload.dart';
part 'callflowcontrol/src/user_state.dart';

/// Config service tests
part 'service/src/service-config.dart';
part 'service/configserver.dart';

/// Calendar tests
part 'service/calendar.dart';
part 'service/src/service-calendar.dart';

/// Contact store tests
part 'service/src/storage-contact.dart';
part 'service/contactserver.dart';

/// Database tests
part 'database/src/ivr_store.dart';
part 'database/src/reception_dialplan_store.dart';
part 'database/all_tests.dart';

/// Message store service tests
part 'service/messageserver.dart';
part 'service/src/service-message.dart';
part 'service/src/service-message_queue.dart';
part 'service/src/storage-message.dart';

/// Reception server tests
part 'reception/all_tests.dart';
part 'reception/src/reception_store.dart';

/// User store tests
part 'user/all_tests.dart';
part 'user/src/user_store.dart';

/// Use case tests
part 'use_case/all_tests.dart';
part 'use_case/src/uc-find_contact.dart';
part 'use_case/src/uc-forward_call.dart';
part 'use_case/src/uc-incoming_call.dart';
part 'use_case/src/uc-send_message.dart';

/// Notification server tests
part 'notificationserver/src/notificationserver.dart';
part 'notificationserver/tests.dart';

/// Organization service tests
part 'organization/src/tests.dart';
part 'organization/all_tests.dart';

const String libraryName = 'Test';

