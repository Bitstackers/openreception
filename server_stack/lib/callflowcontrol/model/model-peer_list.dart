part of callflowcontrol.model;

abstract class PeerList implements IterableBase<Peer> {
  /// Singleton reference.
  static ESL.PeerList instance = new ESL.PeerList.empty();

  static ESL.Peer get (String peerID) => instance.get(peerID);

  static void subscribe(Stream<ESL.Packet> eventStream) {
    eventStream.listen(_handlePacket);
  }

  static registerPeer (String peerID, String contact) {
    ESL.Peer peer = instance.get(ESL.Peer.makeKey(peerID));

    if (peer == null) {
      log.fine('Skipping registration of peer ($peerID) from ignored context;');
      return;
    }

    peer.register (contact);

    Notification.broadcastEvent
      (new OREvent.PeerState
        (new ORModel.Peer(peer.ID, -1)..registered = peer.registered));
  }

  static unRegisterPeer (String peerID) {
    ESL.Peer peer = instance.get(ESL.Peer.makeKey(peerID));

    if (peer == null) {
      log.fine('Skipping registration of peer ($peerID) from ignored context;');
      return;
    }

    peer.unregister();
    Notification.broadcastEvent
      (new OREvent.PeerState
        (new ORModel.Peer(peer.ID, -1)..registered = peer.registered));
  }

  static void _handlePacket (ESL.Event event) {
    switch (event.eventName) {
      case (PBXEvent.CUSTOM):
        switch (event.eventSubclass) {
          case ("sofia::register"):
            registerPeer (event.field('username'), event.field('contact'));
            break;

          case ("sofia::unregister"):
            unRegisterPeer (event.field('username'));
            break;
        }
        break;
    }
  }

  static Iterable<Peer> simplify() =>
    instance.map((ESL.Peer peer) => new Peer.fromESLPeer(peer));


}