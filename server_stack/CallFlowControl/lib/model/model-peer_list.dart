part of callflowcontrol.model;

abstract class PeerList {
  /// Singleton reference.
  static ESL.PeerList instance = null;

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

  static void _handlePacket (ESL.Packet packet) {
    switch (packet.eventName) {
      case ("CUSTOM"):
        switch (packet.eventSubclass) {
          case ("sofia::register"):
            registerPeer (packet.field('username'), packet.field('contact'));
            break;

          case ("sofia::unregister"):
            unRegisterPeer (packet.field('username'));
            break;
        }
        break;
    }
  }

}