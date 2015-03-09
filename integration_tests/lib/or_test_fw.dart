library or_test_fw;

import 'package:phonio/phonio.dart' as Phonio;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Transport;
import 'package:openreception_framework/storage.dart' as Storage;
import 'package:openreception_framework/model.dart' as Model;
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'config.dart';

part 'pool.dart';
part 'receptionist.dart';
part 'receptionist_pool.dart';
part 'customer.dart';
part 'customer_pool.dart';

/// Server tests
part 'callflowcontrol/hangup.dart';
part 'messagestore/tests.dart';
part 'managementserver/tests.dart';

/// Use cases
part 'uc-find_contact.dart';
part 'uc-forward_call.dart';
part 'uc-incoming_call.dart';
part 'uc-send_message.dart';
const String libraryName = 'OpenReceptionTest';

