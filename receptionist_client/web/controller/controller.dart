
/**
 * Controllers are a centralized point, from where all actions are performed.
 * Any UI componentes should only listen to Command Events, and update their own
 * state/presentation accordingly.
 * Every component, such as a button, that is able to send commands will inject a
 * command into the command stream (currently event stream, separation will follow).
 */

library controller;

import 'dart:async';
import 'dart:html';

import '../classes/context.dart' as UIContext;
import '../classes/events.dart' as event;
import '../classes/location.dart' as nav;
import '../classes/logger.dart';
import '../model/model.dart' as Model;
import '../service/service.dart' as Service;

import 'package:okeyee/okeyee.dart';
import 'package:openreception_framework/bus.dart';

part 'controller-call.dart';
part 'controller-contact.dart';
part 'controller-context.dart';
part 'controller-extension.dart';
part 'controller-hotkeys.dart';
part 'controller-reception.dart';
part 'controller-user.dart';

const String libraryName = 'controller';
