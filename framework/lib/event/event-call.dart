part of openreception.event;

abstract class CallEvent implements Event {

  final DateTime timestamp;

  final Call   call;

  CallEvent (Call this.call) : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.call(this);

  CallEvent.fromMap (Map map) :
    this.call      = new Call.fromMap             (map[_Key.call]),
    this.timestamp = Util.unixTimestampToDateTime (map[_Key.timestamp]);

}

class CallLock extends CallEvent {

  final String   eventName = _Key.callLock;

  CallLock (Call call) : super (call);
  CallLock.fromMap (Map map) : super.fromMap(map);
}

class CallUnlock extends CallEvent {

  final String   eventName = _Key.callUnlock;

  CallUnlock (Call call) : super (call);
  CallUnlock.fromMap (Map map) : super.fromMap(map);
}

class CallOffer extends CallEvent {

  final String   eventName = _Key.callOffer;

  CallOffer (Call call) : super (call);
  CallOffer.fromMap (Map map) : super.fromMap(map);
}

class CallPark extends CallEvent {

  final String   eventName = _Key.callPark;

  CallPark (Call call) : super(call);
  CallPark.fromMap (Map map) : super.fromMap(map);
}

class CallUnpark extends CallEvent {

  final String   eventName = _Key.callUnpark;

  CallUnpark (Call call) : super (call);
  CallUnpark.fromMap (Map map) : super.fromMap (map);
}

class CallPickup extends CallEvent {

  final String   eventName = _Key.callPickup;

  CallPickup (Call call) : super (call);
  CallPickup.fromMap (Map map) : super.fromMap (map);

}

class CallTransfer extends CallEvent {

  final String   eventName = _Key.callTransfer;

  CallTransfer (Call call) : super(call);
  CallTransfer.fromMap (Map map) : super.fromMap(map);
}

class CallHangup extends CallEvent {

  final String   eventName = _Key.callHangup;

  CallHangup (Call call) : super(call);
  CallHangup.fromMap (Map map) : super.fromMap(map);
}

class CallStateChanged extends CallEvent {

  final String   eventName = _Key.callState;

  CallStateChanged (Call call) : super(call);
  CallStateChanged.fromMap (Map map) : super.fromMap(map);
}

class QueueJoin extends CallEvent {

  final String   eventName = _Key.queueJoin;

  QueueJoin (Call call) : super(call);
  QueueJoin.fromMap (Map map) : super.fromMap(map);
}

class QueueLeave extends CallEvent {

  final String   eventName = _Key.queueJoin;

  QueueLeave (Call call) : super(call);
  QueueLeave.fromMap (Map map) : super.fromMap(map);
}