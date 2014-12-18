library eventbus;

import 'package:event_bus/event_bus.dart';

import '../menu.dart';

abstract class BaseEvent {}

class WindowChangedEvent implements BaseEvent {
  String window;
  int receptionId;

  WindowChangedEvent.DialplanWithReception(int this.receptionId) {
    window = Menu.DIALPLAN_WINDOW;
  }
}

class OrganizationAddedEvent implements BaseEvent {
  final int organizationId;

  OrganizationAddedEvent([int this.organizationId]);
}

/**
 * Contains the id of the delete organization.
 */
class OrganizationRemovedEvent implements BaseEvent {
  final int organizationId;

  OrganizationRemovedEvent(int this.organizationId);
}

class ReceptionAddedEvent implements BaseEvent {
  final int organizationId;

  ReceptionAddedEvent(int this.organizationId);
}

class ReceptionRemovedEvent implements BaseEvent {
  final int organizationId;
  final int receptionId;

  ReceptionRemovedEvent(int this.organizationId, int this.receptionId);
}

class ContactAddedEvent implements BaseEvent {
  final int contactId;

  ContactAddedEvent([int this.contactId]);
}
/**
 * Contains the id of the contact removed.
 */
class ContactRemovedEvent implements BaseEvent {
  final int contactId;

  ContactRemovedEvent([int this.contactId]);
}

class ReceptionContactAddedEvent implements BaseEvent {
  final int receptionId;
  final int contactId;

  ReceptionContactAddedEvent(int this.receptionId, int this.contactId);
}

class ReceptionContactRemovedEvent implements BaseEvent {
  final int receptionId;
  final int contactId;

  ReceptionContactRemovedEvent(int this.receptionId, int this.contactId);
}

class UserAddedEvent implements BaseEvent {
  final int userId;

  UserAddedEvent(int this.userId);
}

class UserRemovedEvent implements BaseEvent {
  final int userId;

  UserRemovedEvent(int this.userId);
}

class DialplanChangedEvent implements BaseEvent {
  final int receptionId;

  DialplanChangedEvent(int this.receptionId);
}

class PlaylistChangedEvent implements BaseEvent {
  final int playlistId;

  PlaylistChangedEvent(int this.playlistId);
}

class PlaylistAddedEvent implements BaseEvent {
  final int playlistId;

  PlaylistAddedEvent(int this.playlistId);
}

class PlaylistRemovedEvent implements BaseEvent {
  final int playlistId;

  PlaylistRemovedEvent(int this.playlistId);
}

final EventType<Map> windowChanged = new EventType<Map>();

EventBus _bus = new EventBus();
EventBus get bus => _bus;
