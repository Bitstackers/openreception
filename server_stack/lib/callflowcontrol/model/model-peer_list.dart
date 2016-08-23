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

PeerList peerlist = new PeerList();

bool peerIsInAcceptedContext(ESL.Peer peer) =>
    config.callFlowControl.peerContexts.contains(peer.context);

class PeerList {
  Map<String, ORModel.Peer> _peers = {};

  /**
   * Retrive a single [Peer], identified by [peerName] from the list.
   */
  ORModel.Peer get(String peerName) => this.contains(peerName)
      ? (_peers[peerName]
        ..channelCount = ChannelList.instance.activeChannelCount(peerName))
      : throw new NotFound(peerName);

  int get length => _peers.keys.length;

  /**
   *
   */
  void add(ORModel.Peer peer) {
    _peers[peer.name] = peer;
  }

  /**
   *
   */
  bool contains(String peerName) => _peers.containsKey(peerName);

  registerPeer(String peerName) {
    ORModel.Peer peer = get(peerName);

    peer.registered = true;
    notification.broadcastEvent(new OREvent.PeerState(peer));
  }

  unregisterPeer(String peerName) {
    ORModel.Peer peer = get(peerName);

    peer.registered = false;
    notification.broadcastEvent(new OREvent.PeerState(peer));
  }

  void handlePacket(ESL.Event event) {
    switch (event.eventName) {
      case (PBXEvent.custom):
        switch (event.eventSubclass) {
          case (PBXEvent.sofiaRegister):
            final String peerName = event.fields['username'];

            if (this.contains(peerName)) {
              registerPeer(peerName);
            } else {
              log.fine('Skipping registration of '
                  'peer ($peerName) from ignored context;');
            }

            break;

          case (PBXEvent.sofiaUnregister):
            final String peerName = event.fields['username'];

            if (this.contains(peerName)) {
              unregisterPeer(peerName);
            } else {
              log.fine('Skipping unregistration of '
                  'peer ($peerName) from ignored context;');
            }
            break;
        }
        break;
    }
  }

  List toJson() => _peers.values
      .map((peer) => peer
        ..channelCount = ChannelList.instance.activeChannelCount(peer.name))
      .toList(growable: false);
}
