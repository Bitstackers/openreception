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

    peer.register (contact);
    Notification.broadcast(ClientNotification.peerState (peer));
  }

  static unRegisterPeer (String peerID) {
    ESL.Peer peer = instance.get(ESL.Peer.makeKey(peerID));
    peer.unregister();
    Notification.broadcast(ClientNotification.peerState (peer));
  }

  static void _handlePacket (ESL.Event event) {
    switch (event.eventName) {
      case ("CUSTOM"):
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