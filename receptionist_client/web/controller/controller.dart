library controller;

import 'dart:async';
import 'dart:html';

import 'package:okeyee/okeyee.dart';
import 'package:openreception_framework/bus.dart';
import 'package:logging/logging.dart';
import '../model/model.dart' as Model;
import '../service/service.dart' as Service;

part 'controller-call.dart';
part 'controller-context.dart';
part 'controller-hotkeys.dart';
part 'controller-navigation.dart';

const String libraryName = "Controller";

enum Context {Home,
              Homeplus,
              CalendarEdit,
              Messages}

enum Widget {AgentInfo,
             CalendarEditor,
             ContactCalendar,
             ContactData,
             ContactSelector,
             MessageCompose,
             ReceptionCalendar,
             ReceptionCommands,
             ReceptionAltNames,
             MessageArchiveFilter}
