/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

///
/// Event model classes and utilities.
///
/// The events are an integrated part of the core of OpenReception. Every
/// time a change happens, either in a persistent or transient object, an
/// event is sent to every subsystem that needs to respond to this change.
///
/// Example of a subsystems in this context are clients that need to update
/// their UI, based on call-state changes. It may also be a server-side
/// cache/prefetching service that responds to a change in a persistent
/// datastore (for example, a deletion) and updates its locals
/// views/caches accordingly.
library openreception.framework.event;

import 'package:logging/logging.dart';
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/util.dart' as util;

part 'event/call/event-call.dart';
part 'event/call/event-call_assign.dart';
part 'event/call/event-call_hangup.dart';
part 'event/call/event-call_lock.dart';
part 'event/call/event-call_offer.dart';
part 'event/call/event-call_park.dart';
part 'event/call/event-call_pickup.dart';
part 'event/call/event-call_queue_enter.dart';
part 'event/call/event-call_queue_leave.dart';
part 'event/call/event-call_state_reload.dart';
part 'event/call/event-call_statechange.dart';
part 'event/call/event-call_transfer.dart';
part 'event/call/event-call_unassign.dart';
part 'event/call/event-call_unlock.dart';
part 'event/call/event-call_unpark.dart';
part 'event/event-calendar.dart';
part 'event/event-channel.dart';
part 'event/event-client_connection.dart';
part 'event/event-contact.dart';
part 'event/event-dialplan.dart';
part 'event/event-focus_change.dart';
part 'event/event-ivr_menu.dart';
part 'event/event-message.dart';
part 'event/event-organization.dart';
part 'event/event-peer_state.dart';
part 'event/event-reception.dart';
part 'event/event-reception_contact.dart';
part 'event/event-user.dart';
part 'event/event-user_state.dart';
part 'event/event-widget_select.dart';

/**
 * 'Enum' representing different outcomes of an change.
 */
abstract class Change {
  /// Object is created.
  static const String created = 'created';

  /// Object is updated.
  static const String updated = 'updated';

  /// Object is deleted.
  static const String deleted = 'deleted';
}

/**
 * Keys for the serialization and deserialization.
 */
abstract class _Key {
  static const String _uid = 'uid';
  static const _dialplanChange = 'dialplanChange';
  static const _extension = 'extension';
  static const _ivrMenuChange = 'ivrMenuChange';
  static const _menuName = 'menuName';
  static const _createdAt = 'createdAt';

  static const _call = 'call';
  static const _peer = 'peer';
  static const _channel = 'channel';
  static const _event = 'event';
  static const _calendarChange = 'calendarChange';
  static const _messageChange = 'messageChange';
  static const _contactChange = 'contactChange';
  static const _receptionData = 'receptionData';
  static const _receptionChange = 'receptionChange';
  static const _userChange = 'userChange';
  static const _organizationChange = 'organizationChange';
  static const _receptionID = 'rid';
  static const _contactID = 'cid';
  static const _messageID = 'mid';
  static const _organizationID = 'oid';
  static const _hangupCause = 'hangupCause';
  static const _widgetSelect = 'widgetSelect';
  static const _widget = 'widget';
  static const _focusChange = 'focusChange';
  static const _inFocus = 'inFocus';
  static const _messageState = 'messageState';

  static const _owner = 'owner';
  static const _entryID = 'eid';
  static const _id = 'id';
  static const _timestamp = 'timestamp';
  static const _modifierUid = 'modifier';
  static const _changedBy = 'changedBy';
  static const _paused = 'paused';

  static const _connectionState = 'connectionState';

  static const _callAssign = 'call_assign';
  static const _callUnassign = 'call_unassign';
  static const _callOffer = 'call_offer';
  static const _callLock = 'call_lock';
  static const _callUnlock = 'call_unlock';
  static const _callPickup = 'call_pickup';
  static const _callState = 'call_state';
  static const _callHangup = 'call_hangup';
  static const _callPark = 'call_park';
  static const _callUnpark = 'call_unpark';
  static const _callTransfer = 'call_transfer';
  static const _queueJoin = 'queue_join';
  static const _queueLeave = 'queue_leave';
  static const _peerState = 'peer_state';
  static const _channelState = 'channel_state';
  static const _userState = 'userState';
  static const _state = 'state';
  static const _callStateReload = 'callStateReload';
}

/**
 * Superclass for events. It's only real purpose is to provide a common
 * interface for [Event] objects, and a parsing factory constructor.
 */
abstract class Event {
  static final Logger _log = new Logger('openreception.framework.event.Event');

  /// The creation time of the event.
  DateTime get timestamp;

  /// The name of the event. Identifies the type of the object in the
  /// serialization/deserialization.
  String get eventName;

  /**
   * Every specialized class needs a toJson function.
   */
  Map toJson();

  /**
   * Parse an an event that has already been deserialized from JSON string.
   *
   * Throws a [FormatException] if the map is not a valid event.
   */
  factory Event.parse(Map map) {
    final String eventName = map[_Key._event];
    try {
      switch (eventName) {
        case _Key._widgetSelect:
          return new WidgetSelect.fromMap(map);

        case _Key._focusChange:
          return new FocusChange.fromMap(map);

        case _Key._peerState:
          return new PeerState.fromMap(map);

        case _Key._queueJoin:
          return new QueueJoin.fromMap(map);

        case _Key._queueLeave:
          return new QueueLeave.fromMap(map);

        case _Key._callLock:
          return new CallLock.fromMap(map);

        case _Key._callUnlock:
          return new CallUnlock.fromMap(map);

        case _Key._callOffer:
          return new CallOffer.fromMap(map);

        case _Key._callTransfer:
          return new CallTransfer.fromMap(map);

        case _Key._callUnpark:
          return new CallUnpark.fromMap(map);

        case _Key._callPark:
          return new CallPark.fromMap(map);

        case _Key._callHangup:
          return new CallHangup.fromMap(map);

        case _Key._callState:
          return new CallStateChanged.fromMap(map);

        case _Key._callPickup:
          return new CallPickup.fromMap(map);

        case _Key._channelState:
          return new ChannelState.fromMap(map);

        case _Key._userState:
          return new UserState.fromMap(map);

        case _Key._calendarChange:
          return new CalendarChange.fromMap(map);

        case _Key._contactChange:
          return new ContactChange.fromMap(map);

        case _Key._organizationChange:
          return new OrganizationChange.fromMap(map);

        case _Key._receptionChange:
          return new ReceptionChange.fromMap(map);

        case _Key._receptionData:
          return new ReceptionData.fromMap(map);

        case _Key._connectionState:
          return new ClientConnectionState.fromMap(map);

        case _Key._messageChange:
          return new MessageChange.fromMap(map);

        case _Key._userChange:
          return new UserChange.fromMap(map);

        case _Key._callStateReload:
          return new CallStateReload.fromMap(map);

        case _Key._dialplanChange:
          return new DialplanChange.fromMap(map);

        case _Key._ivrMenuChange:
          return new IvrMenuChange.fromMap(map);

        default:
          throw new FormatException('Unsupported event type: $eventName');
      }
    } catch (error, stackTrace) {
      _log.severe('Failed to parse map as event. Map: $map');
      _log.severe(error, stackTrace);

      throw new FormatException('Failed to cast map as event.');
    }
  }
}
