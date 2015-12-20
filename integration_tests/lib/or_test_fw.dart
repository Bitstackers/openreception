library or_test_fw;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' show Random;

import 'package:phonio/phonio.dart' as Phonio;
import 'package:esl/esl.dart' as esl;
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

/// Dialplan deployment tests
part 'service/dialplan_deployment.dart';
part 'service/src/dialplan_deployment.dart';

/// Authserver tests
part 'service/src/service-auth.dart';
part 'service/authserver.dart';

/// Benchmark tests
part 'benchmark/src/tests.dart';
part 'benchmark/all_tests.dart';

/// Callflow server tests
part 'service/callflowcontrol.dart';
part 'service/src/service-active_recording.dart';
part 'service/src/service-call_hangup.dart';
part 'service/src/service-call_list.dart';
part 'service/src/service-call_originate.dart';
part 'service/src/service-call_park.dart';
part 'service/src/service-call_pickup.dart';
part 'service/src/service-call_transfer.dart';
part 'service/src/service-peer.dart';
part 'service/src/service-state_reload.dart';
part 'service/src/service-user_state.dart';

part 'service/src/service-config.dart';
part 'service/configserver.dart';

/// Calendar tests
part 'service/calendar.dart';
part 'service/src/service-calendar.dart';

/// Contact store tests
part 'service/src/storage-contact.dart';
part 'service/contactserver.dart';

/// Database tests
part 'service/src/storage-calendar.dart';
part 'service/src/storage-ivr.dart';
part 'database/src/reception_dialplan_store.dart';
part 'database/all_tests.dart';

part 'service/ivrserver.dart';
part 'service/dialplanserver.dart';

/// Message store service tests
part 'service/messageserver.dart';
part 'service/src/service-message.dart';
part 'service/src/service-message_queue.dart';
part 'service/src/storage-message.dart';

/// Reception server tests
part 'service/receptionserver.dart';
part 'service/src/service-reception.dart';

/// User store tests
part 'service/userserver.dart';
part 'service/src/service-user.dart';

/// Use case tests
part 'use_case/all_tests.dart';
part 'use_case/src/uc-find_contact.dart';
part 'use_case/src/uc-forward_call.dart';
part 'use_case/src/uc-incoming_call.dart';
part 'use_case/src/uc-send_message.dart';

/// Notification server tests
part 'service/src/service-notification.dart';
part 'service/notificationserver.dart';

/// Organization service tests
part 'service/src/service-organization.dart';
part 'service/organizationserver.dart';

const String libraryName = 'Test';

