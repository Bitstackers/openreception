library openreception_tests.service.call;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/pbx-keys.dart' as pbxKey;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:openreception_tests/support.dart';
import 'package:phonio/phonio.dart' as phonio;
import 'package:test/test.dart';

part 'call/service-active_recording.dart';
part 'call/service-call_hangup.dart';
part 'call/service-call_list.dart';
part 'call/service-call_originate.dart';
part 'call/service-call_park.dart';
part 'call/service-call_pickup.dart';
part 'call/service-call_transfer.dart';

const String _namespace = 'test.service';
