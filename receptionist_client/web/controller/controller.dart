library controller;

import 'dart:async';
import 'dart:html';

import '../enums.dart';
import '../model/model.dart' as Model;
import '../service/service.dart' as Service;

import 'package:okeyee/okeyee.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/bus.dart';
import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/model.dart' as ORModel;

part 'controller-call.dart';
part 'controller-contact.dart';
part 'controller-hotkeys.dart';
part 'controller-navigation.dart';
part 'controller-reception.dart';
part 'controller-user.dart';

const String libraryName = 'controller';