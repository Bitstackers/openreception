library ort.service.call;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:orf/event.dart' as event;
import 'package:orf/exceptions.dart';
import 'package:orf/model.dart' as model;
import 'package:orf/pbx-keys.dart' as pbxKey;
import 'package:orf/service.dart' as service;
import 'package:orf/storage.dart' as storage;
import 'package:ort/support.dart';
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
