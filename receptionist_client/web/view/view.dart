library view;

import 'package:event_bus/event_bus.dart';

import 'dart:async';
import 'dart:html';
import '../classes/events.dart' as event;
import '../model/model.dart' as model;
import '../constants.dart' as constant;
import '../service/service.dart' as Service;
import '../storage/storage.dart' as Storage;
import '../components.dart' as Component;
import '../classes/id.dart' as id;
import '../classes/location.dart' as nav;
import '../controller/controller.dart' as Controller;
import '../classes/events.dart' as Event;
import '../classes/logger.dart';

import '../classes/context.dart';

part 'view-call-management.dart';
part 'view-contextswitcher.dart';
part 'view-message-list.dart';
part 'view-notification.dart';
part 'view-reception-events.dart';
part 'view-nudge.dart';
part 'view-message.dart';

const String libraryName = "view";

abstract class StyleClass {
  static const String NUDGE = 'nudge';
  
  static String selector(String styleClass) {
    return '.$styleClass';
  }
}