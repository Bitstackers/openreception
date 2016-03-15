library openreception_tests.service;

export 'package:openreception_tests/service/service-call.dart';

import 'dart:io';
import 'dart:async';

import 'package:esl/esl.dart' as esl;
import 'package:phonio/phonio.dart' as phonio;

import 'package:logging/logging.dart';

import 'package:openreception_tests/support.dart';
import 'package:openreception_tests/config.dart';

import 'package:openreception_framework/resource.dart' as resource;
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/event.dart' as event;

import 'package:unittest/unittest.dart';

part 'service/service-auth.dart';
part 'service/service-config.dart';
part 'service/service-contact.dart';
part 'service/service-dialplan_deployment.dart';
part 'service/service-dialplan.dart';
part 'service/service-message_queue.dart';
part 'service/service-message.dart';
part 'service/service-notification.dart';
part 'service/service-organization.dart';
part 'service/service-peer.dart';
part 'service/service-peeraccount.dart';
part 'service/service-reception.dart';
part 'service/service-state_reload.dart';
part 'service/service-user.dart';
part 'service/service-user_state.dart';

const String libraryName = 'test.service';
const String _namespace = libraryName;
