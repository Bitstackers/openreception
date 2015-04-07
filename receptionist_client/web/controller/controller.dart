library controller;

import 'dart:async';
import 'dart:html';

import 'package:okeyee/okeyee.dart';
import 'package:openreception_framework/bus.dart';

part 'controller-hotkeys.dart';
part 'controller-navigation.dart';

enum Context {Home,
              Homeplus,
              CalendarEdit,
              Messages}

enum Widget {AgentInfo,
             CalendarEditor,
             ContactCalendar,
             ContactData,
             ReceptionCalendar,
             ReceptionAltNames,
             MessageArchiveFilter}
