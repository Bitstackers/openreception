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

part of openreception.call_flow_control_server.model;

abstract class PeerList implements IterableBase<Peer> {
  /// Singleton reference.
  static ESL.PeerList instance = new ESL.PeerList.empty();

  static ESL.Peer get(String peerID) => instance.get(peerID);

  static void subscribe(Stream<ESL.Packet> eventStream) {
    eventStream.listen(_handlePacket);
  }

  static registerPeer(String peerID, String contact) {
    ESL.Peer peer = instance.get(ESL.Peer.makeKey(peerID));

    if (peer == null) {
      log.fine('Skipping registration of peer ($peerID) from ignored context;');
      return;
    }

    peer.register(contact);

    Notification.broadcastEvent(new OREvent.PeerState(
        new ORModel.Peer(peer.ID)..registered = peer.registered));
  }

  static unRegisterPeer(String peerID) {
    ESL.Peer peer = instance.get(ESL.Peer.makeKey(peerID));

    if (peer == null) {
      log.fine('Skipping registration of peer ($peerID) from ignored context;');
      return;
    }

    peer.unregister();
    Notification.broadcastEvent(new OREvent.PeerState(
        new ORModel.Peer(peer.ID)..registered = peer.registered));
  }

  static void _handlePacket(ESL.Event event) {
    switch (event.eventName) {
      case (PBXEvent.CUSTOM):
        switch (event.eventSubclass) {
          case (PBXEvent.SOFIA_REGISTER):
            registerPeer(event.field('username'), event.field('contact'));
            break;

          case (PBXEvent.SOFIA_UNREGISTER):
            unRegisterPeer(event.field('username'));
            break;
        }
        break;
    }
  }

  static Iterable<Peer> simplify() =>
      instance.map((ESL.Peer peer) => new Peer.fromESLPeer(peer));
}
