library openreception.event;

import 'package:logging/logging.dart';

import 'util.dart' as Util;
import 'model.dart';

part 'event/event-calendar.dart';
part 'event/event-call.dart';
part 'event/event-channel.dart';
part 'event/event-contact.dart';
part 'event/event-message.dart';
part 'event/event-organization.dart';
part 'event/event-user_state.dart';
part 'event/event-peer_state.dart';
part 'event/event-reception.dart';
part 'event/event-reception_contact.dart';
part 'event/event-template.dart';

/// Keys for the map.

abstract class _Key {
  static const call = 'call';
  static const peer = 'peer';
  static const channel = 'channel';
  static const event = 'event';
  static const calendarEntry = 'calendarEntry';
  static const calendarChange = 'calendarChange';
  static const messageChange = 'messageChange';
  static const contactChange = 'contactChange';
  static const receptionContactChange = 'receptionContactChange';
  static const receptionChange = 'receptionChange';
  static const organizationChange = 'organizationChange';
  static const receptionID = 'rid';
  static const contactID = 'cid';
  static const messageID = 'mid';
  static const organizationID = 'oid';

  static const entryID = 'eid';
  static const ID = 'id';
  static const timestamp = 'timestamp';
  static const userID = 'userID';
  static const connectionCount = 'connectionCount';

  static const connectionState = 'connectionState';
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

  static const contactCalendarEntryCreate = 'contactCalendarEntryCreate';
  static const contactCalendarEntryUpdate = 'contactCalendarEntryUpdate';
  static const contactCalendarEntryDelete = 'contactCalendarEntryDelete';

  static const receptionCalendarEntryCreate = 'receptionCalendarEntryCreate';
  static const receptionCalendarEntryUpdate = 'receptionCalendarEntryUpdate';
  static const receptionCalendarEntryDelete = 'receptionCalendarEntryDelete';
}

abstract class Event {

  static final Logger log = new Logger('$libraryName.Event');

  DateTime get timestamp;
  String   get eventName;
  Map      get asMap;

  Map toJson() => this.asMap;

  Event.fromMap(Map map);

  factory Event.parse (Map map) {
    try {
      switch (map[_Key.event]) {
        case _Key.peerState:
          return new PeerState.fromMap(map);

        case _Key.queueJoin:
          return new QueueJoin.fromMap(map);

        case _Key.queueLeave:
          return new QueueLeave.fromMap(map);

        case _Key.callLock:
          return new CallLock.fromMap(map);

        case _Key.callUnlock:
          return new CallUnlock.fromMap(map);

        case _Key.callOffer:
          return new CallOffer.fromMap(map);

        case _Key.callTransfer:
          return new CallTransfer.fromMap(map);

        case _Key.callUnpark:
          return new CallUnpark.fromMap(map);

        case _Key.callPark:
          return new CallPark.fromMap(map);

        case _Key.callHangup:
          return new CallHangup.fromMap(map);

        case _Key.callState:
          return new CallStateChanged.fromMap(map);

        case _Key.callPickup:
          return new CallPickup.fromMap(map);

        case _Key.channelState:
          return new ChannelState.fromMap(map);

        case _Key.userState:
          return new UserState.fromMap(map);

        case _Key.calendarChange:
          return new CalendarChange.fromMap(map);

        case _Key.contactChange:
          return new ContactChange.fromMap(map);

        case _Key.organizationChange:
          return new OrganizationChange.fromMap(map);

        case _Key.receptionChange:
          return new ReceptionChange.fromMap(map);

        case _Key.receptionContactChange:
          return new ReceptionContactChange.fromMap(map);

        case _Key.connectionState:
          return new ClientConnectionState.fromMap(map);

        case _Key.messageChange:
          return new MessageChange.fromMap(map);
        default:
          log.severe('Unsupported event type: ${map['event']}');
      }
    } catch (error, stackTrace) {
      log.severe('Failed to parse $map');
      log.severe(error, stackTrace);
    }
  }
}