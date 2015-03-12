library or_test_fw;

import 'package:phonio/phonio.dart' as Phonio;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Transport;
import 'package:openreception_framework/storage.dart' as Storage;
import 'package:openreception_framework/model.dart' as Model;
import 'dart:async';
import 'dart:collection';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'config.dart';

part 'support/pool.dart';
part 'support/receptionist.dart';
part 'support/receptionist_pool.dart';
part 'support/customer.dart';
part 'support/customer_pool.dart';
part 'support/support_tools.dart';

/// Server tests
part 'authserver/tests.dart';
part 'callflowcontrol/tests.dart';
part 'messagestore/tests.dart';
part 'managementserver/tests.dart';

/// Use cases
part 'use_case/uc-find_contact.dart';
part 'use_case/uc-forward_call.dart';
part 'use_case/uc-incoming_call.dart';
part 'use_case/uc-send_message.dart';
const String libraryName = 'OpenReceptionTest';

