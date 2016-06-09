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

library openreception.framework.event;

import 'package:logging/logging.dart';

import 'package:openreception.framework/util.dart' as util;
import 'package:openreception.framework/model.dart' as model;

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
part 'event/call/event-call.dart';
part 'event/event-calendar.dart';
part 'event/event-channel.dart';
part 'event/event-client_connection.dart';
part 'event/event-contact.dart';
part 'event/event-message.dart';
part 'event/event-organization.dart';
part 'event/event-peer_state.dart';
part 'event/event-reception.dart';
part 'event/event-reception_contact.dart';
part 'event/event-template.dart';
part 'event/event-user.dart';
part 'event/event-user_state.dart';
part 'event/event-widget_select.dart';

/**
 * 'Enum' representing different outcomes of an change.
 */
abstract class Change {
  static const String created = 'created';
  static const String updated = 'updated';
  static const String deleted = 'deleted';
}

/**
 * Keys for the serialization and deserialization.
 */
abstract class Key {
  static const call = 'call';
  static const peer = 'peer';
  static const channel = 'channel';
  static const event = 'event';
  static const calendarEntry = 'calendarEntry';
  static const calendarChange = 'calendarChange';
  static const endpointChange = 'endpointChange';
  static const messageChange = 'messageChange';
  static const contactChange = 'contactChange';
  static const receptionData = 'receptionData';
  static const receptionChange = 'receptionChange';
  static const userChange = 'userChange';
  static const organizationChange = 'organizationChange';
  static const receptionID = 'rid';
  static const contactID = 'cid';
  static const messageID = 'mid';
  static const organizationID = 'oid';
  static const hangupCause = 'hangupCause';
  static const widgetSelect = 'widgetSelect';
  static const widget = 'widget';
  static const inFocus = 'inFocus';
  static const messageState = 'messageState';

  static const address = 'address';
  static const addressType = 'addressType';

  static const owner = 'owner';
  static const entryID = 'eid';
  static const id = 'id';
  static const timestamp = 'timestamp';
  static const modifierUid = 'modifier';
  static const changedBy = 'changedBy';
  static const connectionCount = 'connectionCount';

  static const connectionState = 'connectionState';

  static const callAssign = 'call_assign';
  static const callUnassign = 'call_unassign';
  static const callOffer = 'call_offer';
  static const callLock = 'call_lock';
  static const callUnlock = 'call_unlock';
  static const callPickup = 'call_pickup';
  static const callState = 'call_state';
  static const callHangup = 'call_hangup';
  static const callPark = 'call_park';
  static const callUnpark = 'call_unpark';
  static const callTransfer = 'call_transfer';
  static const callBridge = 'call_bridge';
  static const queueJoin = 'queue_join';
  static const queueLeave = 'queue_leave';
  static const peerState = 'peer_state';
  static const originateFailed = 'originate_failed';
  static const originateSuccess = 'originate_success';
  static const channelState = 'channel_state';
  static const userState = 'userState';
  static const state = 'state';
  static const callStateReload = 'callStateReload';
}

const String _libraryName = 'openreception.framework.event';

/**
 * Superclass for events. It's only real purpose is to provide a common
 * interface for [Event] objects, and a parsing factory constructor.
 */
abstract class Event {
  static final Logger _log = new Logger('$_libraryName.Event');

  DateTime get timestamp;
  String get eventName;

  /**
   * Every specialized class needs a toJson function.
   */
  Map toJson();

  /**
   * Parse an an event that has already been deserialized from JSON string.
   * TODO: Throw a [FormatException] from this constructor instead of
   * returning a null object.
   */
  factory Event.parse(Map map) {
    try {
      switch (map[Key.event]) {
        case Key.peerState:
          return new PeerState.fromMap(map);

        case Key.queueJoin:
          return new QueueJoin.fromMap(map);

        case Key.queueLeave:
          return new QueueLeave.fromMap(map);

        case Key.callLock:
          return new CallLock.fromMap(map);

        case Key.callUnlock:
          return new CallUnlock.fromMap(map);

        case Key.callOffer:
          return new CallOffer.fromMap(map);

        case Key.callTransfer:
          return new CallTransfer.fromMap(map);

        case Key.callUnpark:
          return new CallUnpark.fromMap(map);

        case Key.callPark:
          return new CallPark.fromMap(map);

        case Key.callHangup:
          return new CallHangup.fromMap(map);

        case Key.callState:
          return new CallStateChanged.fromMap(map);

        case Key.callPickup:
          return new CallPickup.fromMap(map);

        case Key.channelState:
          return new ChannelState.fromMap(map);

        case Key.userState:
          return new UserState.fromMap(map);

        case Key.calendarChange:
          return new CalendarChange.fromMap(map);

        case Key.contactChange:
          return new ContactChange.fromMap(map);

        case Key.organizationChange:
          return new OrganizationChange.fromMap(map);

        case Key.receptionChange:
          return new ReceptionChange.fromMap(map);

        case Key.receptionData:
          return new ReceptionData.fromMap(map);

        case Key.connectionState:
          return new ClientConnectionState.fromMap(map);

        case Key.messageChange:
          return new MessageChange.fromMap(map);

        case Key.userChange:
          return new UserChange.fromMap(map);

        case Key.callStateReload:
          return new CallStateReload.fromMap(map);

        default:
          _log.severe('Unsupported event type: ${map['event']}');
      }
    } catch (error, stackTrace) {
      _log.severe('Failed to parse $map');
      _log.severe(error, stackTrace);
    }

    return null;
  }
}
