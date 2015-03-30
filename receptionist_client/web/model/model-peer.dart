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

part of model;

class PeerState  {

  static final UNKNOWN      = new PeerState('Unknown');
  static final REGISTERED   = new PeerState('Registered');
  static final UNREGISTERED = new PeerState('Unregistered');

  String _name;

  PeerState (this._name);

  @override
  operator == (PeerState other) => this._name.toLowerCase() == other._name.toLowerCase();

  @override
  int get hashCode => this._name.hashCode;

  @override
  String toString () => this._name;
}

class Peer extends ORModel.Peer {

  static const String className = "${libraryName}.Peer";

  static Bus<Peer> _stateChange = new Bus<Peer>();
  static Stream<Peer> get onReceptionChange => _stateChange.stream;

  DateTime lastSeen = null;

  Peer.fromMap(Map map) : super.fromMap(map);

  void update (Peer newPeer) {
    assert (this.ID == newPeer.ID);

    if (newPeer.registered) {
      this.lastSeen = new DateTime.now();
    }

    this.registered = newPeer.registered;
    _stateChange.fire(this);
  }

  /**
   * Two peers are considered equal, if their ID's are.
   */
  @override
  bool operator == (Peer other) => this.ID == other.ID;

  /**
   * See the equals operator definition.
   */
  @override
  int get hashCode => this.ID.hashCode;

  /**
   * String representation of the peer.
   *
   * Returns string with the format "ID - status".
   */
  @override
  String toString () => '${this.ID} - registered:${this.registered}.';

}