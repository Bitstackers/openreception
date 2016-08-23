library openreception_tests.support;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' show Random;

import 'package:logging/logging.dart';
import 'package:openreception.framework/configuration.dart' as or_conf;
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/exceptions.dart';
import 'package:openreception.framework/filestore.dart' as filestore;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/service-io.dart' as service;
import 'package:openreception.framework/service-io.dart' as Transport;
import 'package:openreception.framework/service.dart' as Service;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:openreception_tests/config.dart';
import 'package:openreception_tests/filestore.dart' as filestore;
import 'package:openreception_tests/process.dart' as process;
import 'package:openreception_tests/support/support-auth.dart';
import 'package:phonio/phonio.dart' as Phonio;
import 'package:test/test.dart';

export 'package:openreception_tests/support/support-auth.dart';

part 'support/customer.dart';
part 'support/customer_pool.dart';
part 'support/pool.dart';
part 'support/randomizer.dart';
part 'support/receptionist.dart';
part 'support/receptionist_pool.dart';
part 'support/support-service_agent.dart';
part 'support/support-test_environment.dart';

/**
 * Converts a Dart DateTime WeekDay into a [model.Weekday].
 */
model.WeekDay toWeekDay(int weekday) {
  if (weekday == DateTime.MONDAY) {
    return model.WeekDay.mon;
  } else if (weekday == DateTime.TUESDAY) {
    return model.WeekDay.tue;
  } else if (weekday == DateTime.WEDNESDAY) {
    return model.WeekDay.wed;
  } else if (weekday == DateTime.THURSDAY) {
    return model.WeekDay.thur;
  } else if (weekday == DateTime.FRIDAY) {
    return model.WeekDay.fri;
  } else if (weekday == DateTime.SATURDAY) {
    return model.WeekDay.sat;
  } else if (weekday == DateTime.SUNDAY) {
    return model.WeekDay.sun;
  }

  throw new RangeError('$weekday not in range');
}
