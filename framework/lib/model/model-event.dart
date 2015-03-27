part of openreception.model;

/// Keys for the map.

abstract class EventJSONKey {
  static const call = 'call';
  static const peer = 'peer';
  static const channel = 'channel';
  static const event = 'event';
  static const ID = 'id';
  static const timestamp = 'timestamp';

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
}

abstract class EventTemplate {
  static Map _rootElement(Event event) => {
    EventJSONKey.event     : event.eventName,
    EventJSONKey.timestamp : Util.dateTimeToUnixTimestamp (event.timestamp)
  };

  static Map call(CallEvent event) =>
      _rootElement(event)..addAll( {EventJSONKey.call : event.call});

  static Map peer(PeerState event) =>
      _rootElement(event)..addAll( {EventJSONKey.peer : event.peer});

  static Map userState(UserStateEvent event) =>
      _rootElement(event)..addAll(event.status.asMap);


  static Map channel(ChannelState event) =>
      _rootElement(event)..addAll(
           {EventJSONKey.channel :
             {EventJSONKey.ID : event.channelID}});

}

abstract class Event {

  static final Logger log = new Logger('$libraryName.Event');

  DateTime get timestamp;
  String   get eventName;

  Map toJson();

  Event.fromMap(Map map);

  factory Event.parse (Map map) {
    try {
      switch (map['event']) {
        case EventJSONKey.peerState:
          return new PeerState.fromMap(map);

        case EventJSONKey.queueJoin:
          return new QueueJoin.fromMap(map);

        case EventJSONKey.queueLeave:
          return new QueueLeave.fromMap(map);

        case EventJSONKey.callLock:
          return new CallLock.fromMap(map);

        case EventJSONKey.callUnlock:
          return new CallUnlock.fromMap(map);

        case EventJSONKey.callOffer:
          return new CallOffer.fromMap(map);

        case EventJSONKey.callTransfer:
          return new CallTransfer.fromMap(map);

        case EventJSONKey.callUnpark:
          return new CallUnpark.fromMap(map);

        case EventJSONKey.callPark:
          return new CallPark.fromMap(map);

        case EventJSONKey.callHangup:
          return new CallHangup.fromMap(map);

        case EventJSONKey.callState:
          return new CallStateChanged.fromMap(map);

        case EventJSONKey.callPickup:
          return new CallPickup.fromMap(map);

        case EventJSONKey.channelState:
          return new ChannelState.fromMap(map);

        case EventJSONKey.userState:
          return new UserStateEvent.fromMap(map);

        default:
          log.severe('Unsupported event type: ${map['event']}');
      }
    } catch (error, stackTrace) {
      log.severe('Failed to parse $map');
      log.severe(error, stackTrace);
    }
  }
}

abstract class CallEvent implements Event {

  final DateTime timestamp;

  final Call   call;

  CallEvent (Call this.call) : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.call(this);

  CallEvent.fromMap (Map map) :
    this.call      = new Call.fromMap             (map[EventJSONKey.call]),
    this.timestamp = Util.unixTimestampToDateTime (map[EventJSONKey.timestamp]);

}

class ChannelState implements Event {
  final DateTime timestamp;
  final String   eventName = EventJSONKey.channelState;
  final String   channelID;

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.channel (this);

  ChannelState(String channelID) :
      this.channelID = channelID,
      this.timestamp = new DateTime.now();

  ChannelState.fromMap (Map map) :
    this.channelID = map[EventJSONKey.channel][EventJSONKey.ID],
    this.timestamp = Util.unixTimestampToDateTime (map[EventJSONKey.timestamp]);
}

class PeerState implements Event {

  final DateTime timestamp;
  final String   eventName = EventJSONKey.peerState;

  final Peer     peer;

  PeerState (Peer this.peer) : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.peer(this);

  PeerState.fromMap (Map map) :
    this.peer      = new Peer.fromMap             (map[EventJSONKey.peer]),
    this.timestamp = Util.unixTimestampToDateTime (map[EventJSONKey.timestamp]);

}

class UserStateEvent implements Event {

  final DateTime timestamp;
  final String   eventName = EventJSONKey.userState;

  final UserStatus   status;

  UserStateEvent (UserStatus this.status) : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.userState(this);

  UserStateEvent.fromMap (Map map) :
    this.status    = new UserStatus.fromMap (map),
    this.timestamp = Util.unixTimestampToDateTime (map[EventJSONKey.timestamp]);

}




class CallLock extends CallEvent {

  final String   eventName = EventJSONKey.callLock;

  CallLock (Call call) : super (call);
  CallLock.fromMap (Map map) : super.fromMap(map);
}

class CallUnlock extends CallEvent {

  final String   eventName = EventJSONKey.callUnlock;

  CallUnlock (Call call) : super (call);
  CallUnlock.fromMap (Map map) : super.fromMap(map);
}

class CallOffer extends CallEvent {

  final String   eventName = EventJSONKey.callOffer;

  CallOffer (Call call) : super (call);
  CallOffer.fromMap (Map map) : super.fromMap(map);
}

class CallPark extends CallEvent {

  final String   eventName = EventJSONKey.callPark;

  CallPark (Call call) : super(call);
  CallPark.fromMap (Map map) : super.fromMap(map);
}

class CallUnpark extends CallEvent {

  final String   eventName = EventJSONKey.callUnpark;

  CallUnpark (Call call) : super (call);
  CallUnpark.fromMap (Map map) : super.fromMap (map);
}

class CallPickup extends CallEvent {

  final String   eventName = EventJSONKey.callPickup;

  CallPickup (Call call) : super (call);
  CallPickup.fromMap (Map map) : super.fromMap (map);

}

class CallTransfer extends CallEvent {

  final String   eventName = EventJSONKey.callTransfer;

  CallTransfer (Call call) : super(call);
  CallTransfer.fromMap (Map map) : super.fromMap(map);
}

class CallHangup extends CallEvent {

  final String   eventName = EventJSONKey.callHangup;

  CallHangup (Call call) : super(call);
  CallHangup.fromMap (Map map) : super.fromMap(map);
}

class CallStateChanged extends CallEvent {

  final String   eventName = EventJSONKey.callState;

  CallStateChanged (Call call) : super(call);
  CallStateChanged.fromMap (Map map) : super.fromMap(map);
}

class QueueJoin extends CallEvent {

  final String   eventName = EventJSONKey.queueJoin;

  QueueJoin (Call call) : super(call);
  QueueJoin.fromMap (Map map) : super.fromMap(map);
}

class QueueLeave extends CallEvent {

  final String   eventName = EventJSONKey.queueJoin;

  QueueLeave (Call call) : super(call);
  QueueLeave.fromMap (Map map) : super.fromMap(map);
}


