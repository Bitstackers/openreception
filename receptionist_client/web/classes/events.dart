library events;

import 'package:event_bus/event_bus.dart';

import 'context.dart';
import 'environment.dart' as environment;
import 'model.dart' as model;
import 'state.dart';

final EventType<Context> activeContextChanged = new EventType<Context>();
final EventType<String> activeWidgetChanged = new EventType<String>();
final EventType<environment.ContextList> contextListUpdated = new EventType<environment.ContextList>();
final EventType<model.Organization> organizationChanged = new EventType<model.Organization>();
final EventType<model.OrganizationList> organizationListChanged = new EventType<model.OrganizationList>();
final EventType<BobState> stateUpdated = new EventType<BobState>();

EventBus _bus = new EventBus();
EventBus get bus => _bus;