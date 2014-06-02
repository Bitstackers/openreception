library eventbus;

import 'package:event_bus/event_bus.dart';

final EventType<Map> windowChanged = new EventType<Map>();

class Invalidate {
  /**
   * The presence of the event is enough to tell the story, 
   *   so no addional information is transported with it.
   */
  static final EventType organizationAdded = new EventType();

  /**
   * Contains the id of the delete organization.
   */
  static final EventType<int> organizationRemoved = new EventType<int>();

  /**
   * Contains organization Id the reception is added to.
   */
  static final EventType<int> receptionAdded = new EventType<int>();

  /**
   * Contains the organization- and reception-id of the removed reception.
   * 
   * Example:
   * { 
   *   "organizationId": 1,
   *   "receptionId": 2 
   * }
   */
  static final EventType<Map> receptionRemoved = new EventType<Map>();

  /**
   * The presence of the event is enough to tell the story, 
   *   so no addional information is transported with it.
   */
  static final EventType<int> contactAdded = new EventType<int>();

  /**
   * Contains the id of the contact removed.
   */
  static final EventType<int> contactRemoved = new EventType<int>();

  /**
   * Contains the reception- and contact-id of the added reception-contact.
   * 
   * Example:
   * { 
   *   "receptionId": 1,
   *   "contactId": 2 
   * }
   */
  static final EventType<Map> receptionContactAdded = new EventType<Map>();

  /**
   * Contains the reception- and contact-id of the removed reception-contact.
   * 
   * Example:
   * { 
   *   "receptionId": 1,
   *   "contactId": 2 
   * }
   */
  static final EventType<Map> receptionContactRemoved = new EventType<Map>();
}

EventBus _bus = new EventBus();
EventBus get bus => _bus;
