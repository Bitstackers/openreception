part of callflowcontrol.model;

/// Keys for the map.
abstract class _Key {
  static const call         = 'call';
  static const peer         = 'peer';
  static const channel      = 'channel';
  static const channelID    = 'id';
  static const FIXME_peerID = 'peer_id';
  static const peerID       = 'id';
  static const registered   = 'registered';
  static const event        = 'event';
  static const timestamp    = 'timestamp';
}

abstract class _Event {
  static const callOffer = 'call_offer';
  static const callLock  = 'call_lock';
  static const callUnlock  = 'call_unlock';
  static const callPickup  = 'call_pickup';
  static const callState  = 'call_state';
  static const callHangup  = 'call_hangup';
  static const callPark  = 'call_park';
  static const callUnpark  = 'call_unpark';
  static const callTransfer  = 'call_transfer';
  static const callBridge  = 'call_bridge';
  static const channelState = 'channel_state';
  static const queueJoin  = 'queue_join';
  static const queueLeave  = 'queue_leave';
  static const peerState  = 'peer_state';
  static const originateFailed  = 'originate_failed';
  static const originateSuccess  = 'originate_success';
}


abstract class ClientNotification {

  static int get unixTimestampNow => (new DateTime.now().millisecondsSinceEpoch~/1000);

   static Map get _rootElement =>
       {_Key.timestamp    : unixTimestampNow};


   static Map createWithCall ({String eventType, Call call}) {
     Map createdEvent = _rootElement;
     createdEvent[_Key.event] = eventType;
     createdEvent[_Key.call]  = call;

     return createdEvent;
   }

   static Map createWithPeer ({String eventType, ESL.Peer peer}) {
     Map createdEvent = _rootElement;
     createdEvent[_Key.event] = eventType;
     createdEvent[_Key.peer]  = peer;

     return createdEvent;
   }

  static Map channelUpdate (ESL.Channel channel ) =>
    {_Key.timestamp : unixTimestampNow,
     _Key.event     : _Event.channelState,
     _Key.channel   :
     { _Key.channelID : channel.UUID
       }
     };

  static callOffer    (Call call) => createWithCall (eventType : _Event.callOffer,    call : call);
  static callLock     (Call call) => createWithCall (eventType : _Event.callLock,     call : call);
  static callUnlock   (Call call) => createWithCall (eventType : _Event.callUnlock,   call : call);
  static callPark     (Call call) => createWithCall (eventType : _Event.callPark,     call : call);
  static callUnpark   (Call call) => createWithCall (eventType : _Event.callUnpark,   call : call);
  static callPickup   (Call call) => createWithCall (eventType : _Event.callPickup,   call : call);
  static callTransfer (Call call) => createWithCall (eventType : _Event.callTransfer, call : call);
  static callHangup   (Call call) => createWithCall (eventType : _Event.callHangup,   call : call);
  static callState    (Call call) => createWithCall (eventType : _Event.callState,    call : call);
  static queueJoin    (Call call) => createWithCall (eventType : _Event.queueJoin,    call : call);
  static queueLeave   (Call call) => createWithCall (eventType : _Event.queueLeave,   call : call);

  static peerState  (ESL.Peer peer) =>
      {_Key.timestamp : unixTimestampNow,
       _Key.event     : _Event.peerState,
       _Key.peer      :
       { _Key.FIXME_peerID : peer.ID,
         _Key.peerID     : peer.ID,
         _Key.registered : peer.registered
         }
       };
}

