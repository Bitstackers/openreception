library controller;

import 'dart:async';
import 'dart:html';

import 'package:okeyee/okeyee.dart';
import 'package:openreception_framework/bus.dart';

part 'controller-hotkeys.dart';
part 'controller-navigation.dart';

enum AppState {Disaster, Loading, Ready}

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
             ReceptionSelector,
             ReceptionAltNames,
             MessageArchiveFilter}
