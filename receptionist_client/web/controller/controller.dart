
/**
 * Controllers are a centralized point, from where all actions are performed.
 * Any UI componentes should only listen to Command Events, and update their own
 * state/presentation accordingly.
 * Every component, such as a button, that is able to send commands will inject a
 * command into the command stream (currently event stream, separation will follow).
 */

library controller;

import 'dart:async';

import '../protocol/protocol.dart' as protocol;
import '../classes/events.dart' as event;
import '../service/service.dart' as Service;
import '../model/model.dart' as model;
import '../classes/context.dart' as UIContext;
import '../classes/location.dart' as nav;

part 'controller-call.dart';
part 'controller-context.dart';
