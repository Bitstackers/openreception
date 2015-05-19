library openreception.event;

import 'package:logging/logging.dart';

import 'util.dart' as Util;
import 'model.dart';

part 'event/event-calendar.dart';
part 'event/event-call.dart';
part 'event/event-channel.dart';
part 'event/event-message.dart';
part 'event/event-user_state.dart';
part 'event/event-peer_state.dart';
part 'event/event-template.dart';

/// Keys for the map.

abstract class Key {
  static const call = 'call';
  static const peer = 'peer';
  static const channel = 'channel';
  static const event = 'event';
  static const calendarEntry = 'calendarEntry';
  static const CalendarChange = 'calendarChange';
  static const MessageChange = 'messageChange';
  static const ReceptionID = 'rid';
  static const ContactID = 'cid';
  static const MessageID = 'mid';

  static const EntryID = 'eid';
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

        case Key.CalendarChange:
          return new CalendarChange.fromMap(map);

        case Key.connectionState:
          return new ClientConnectionState.fromMap(map);

        default:
          log.severe('Unsupported event type: ${map['event']}');
      }
    } catch (error, stackTrace) {
      log.severe('Failed to parse $map');
      log.severe(error, stackTrace);
    }
  }
}