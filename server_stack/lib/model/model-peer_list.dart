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

part of openreception.server.model;

bool peerIsInAcceptedContext(esl.Peer peer) =>
    config.callFlowControl.peerContexts.contains(peer.context);

class PeerList {
  final Logger _log =
      new Logger('openreception.server.call_flow_control.model.PeerList');

  final Map<String, model.Peer> _peers = {};

  final service.NotificationService _notification;
  final ChannelList _channelList;

  PeerList(this._notification, this._channelList);

  /**
   * Retrive a single [Peer], identified by [peerName] from the list.
   */
  model.Peer get(String peerName) => this.contains(peerName)
      ? (_peers[peerName]
        ..channelCount = _channelList.activeChannelCount(peerName))
      : throw new NotFound(peerName);

  int get length => _peers.keys.length;

  /**
   *
   */
  void add(model.Peer peer) {
    _peers[peer.name] = peer;
  }

  /// Clear out the peer list
  void clear() {
    _peers.clear();
  }

  /**
   *
   */
  bool contains(String peerName) => _peers.containsKey(peerName);

  registerPeer(String peerName) {
    model.Peer peer = get(peerName);

    peer.registered = true;
    _notification.broadcastEvent(new event.PeerState(peer));
  }

  unregisterPeer(String peerName) {
    model.Peer peer = get(peerName);

    peer.registered = false;
    _notification.broadcastEvent(new event.PeerState(peer));
  }

  void handlePacket(esl.Event event) {
    switch (event.eventName) {
      case (PBXEvent.custom):
        switch (event.eventSubclass) {
          case (PBXEvent.sofiaRegister):
            final String peerName = event.fields['username'];

            if (this.contains(peerName)) {
              registerPeer(peerName);
            } else {
              _log.fine('Skipping registration of '
                  'peer ($peerName) from ignored context;');
            }

            break;

          case (PBXEvent.sofiaUnregister):
            final String peerName = event.fields['username'];

            if (this.contains(peerName)) {
              unregisterPeer(peerName);
            } else {
              _log.fine('Skipping unregistration of '
                  'peer ($peerName) from ignored context;');
            }
            break;
        }
        break;
    }
  }

  List toJson() => _peers.values
      .map((peer) =>
          peer..channelCount = _channelList.activeChannelCount(peer.name))
      .toList(growable: false);
}
