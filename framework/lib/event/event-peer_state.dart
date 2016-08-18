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

part of openreception.framework.event;

class PeerState implements Event {
  @override
  final DateTime timestamp;
  @override
  final String eventName = _Key._peerState;

  final model.Peer peer;

  PeerState(model.Peer this.peer) : this.timestamp = new DateTime.now();

  @override
  String toString() => this.toJson().toString();

  @override
  Map toJson() => {
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._peer: peer.toJson()
      };

  PeerState.fromMap(Map map)
      : this.peer = new model.Peer.fromMap(map[_Key._peer]),
        this.timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
