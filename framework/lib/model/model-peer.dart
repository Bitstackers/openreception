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

part of openreception.model;

class Peer {
  final String ID;
  final int    channelCount;

  bool registered;

  Peer (this.ID, this.channelCount);

  Map get asMap => {
    Key.ID         : this.ID,
    Key.registered : this.registered,
    Key.activeChannels : this.channelCount
  };

  Peer.fromMap (Map map) :
    this.ID           = map[Key.ID],
    this.registered   = map[Key.registered],
    this.channelCount = map[Key.activeChannels];

  Map toJson() => this.asMap;

  @override
  String toString() => '${this.ID}, registered:${this.registered}';

}