library callflowcontrol.controller;

import 'dart:async';
import '../model/model.dart' as Model;
import '../router.dart';
import '../configuration.dart';
import 'package:esl/esl.dart' as ESL;
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/event.dart' as OREvent;

part 'controller-pbx.dart';

const String libraryName = 'callflowcontrol.controller';
