library events;

import 'package:event_bus/event_bus.dart';

import 'context.dart';
import 'model.dart' as model;
import 'state.dart';

final EventType<Context> activeContextChanged = new EventType<Context>();
final EventType<String> activeWidgetChanged = new EventType<String>();
final EventType<model.Call> callChanged = new EventType<model.Call>();
final EventType<model.Call> callQueueAdd = new EventType<model.Call>();
final EventType<model.Call> callQueueRemove = new EventType<model.Call>();
final EventType<model.Contact> contactChanged = new EventType<model.Contact>();
final EventType<model.Call> localCallQueueAdd = new EventType<model.Call>();
final EventType<model.Organization> organizationChanged = new EventType<model.Organization>();
final EventType<State> stateUpdated = new EventType<State>();

EventBus _bus = new EventBus();
EventBus get bus => _bus;