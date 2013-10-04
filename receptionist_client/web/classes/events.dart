library events;

import 'package:event_bus/event_bus.dart';

import 'environment.dart' as environment;
import 'state.dart';

final EventType<BobState> stateUpdated = new EventType<BobState>();
final EventType<environment.ContextList> contextListUpdated = new EventType<environment.ContextList>();

EventBus _bus = new EventBus();
EventBus get bus => _bus;