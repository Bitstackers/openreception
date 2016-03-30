library openreception_tests.process;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:openreception_tests/support/support-auth.dart';
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-io.dart' as service;

part 'process/process-authserver.dart';
part 'process/process-calendarserver.dart';
part 'process/process-configserver.dart';
part 'process/process-callflowcontrol.dart';
part 'process/process-contactserver.dart';
part 'process/process-dialplanserver.dart';
part 'process/process-freeswitch.dart';
part 'process/process-messageserver.dart';
part 'process/process-messagedispatcher.dart';
part 'process/process-notificationserver.dart';
part 'process/process-receptionserver.dart';
part 'process/process-userserver.dart';

const _namespace = 'test.support.process';

abstract class ServiceProcess {
  Future terminate();
}
