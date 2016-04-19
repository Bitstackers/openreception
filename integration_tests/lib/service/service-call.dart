library openreception_tests.service.call;

import 'dart:async';

import 'package:phonio/phonio.dart' as phonio;
import 'package:logging/logging.dart';
import 'package:openreception_tests/support.dart';

import 'package:openreception_framework/pbx-keys.dart' as pbxKey;
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/event.dart' as event;

import 'package:unittest/unittest.dart';

part 'call/service-active_recording.dart';
part 'call/service-call_hangup.dart';
part 'call/service-call_list.dart';
part 'call/service-call_originate.dart';
part 'call/service-call_park.dart';
part 'call/service-call_pickup.dart';
part 'call/service-call_transfer.dart';

const String _namespace = 'test.service';
