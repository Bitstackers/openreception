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

/**
 *
 */
class Peer {
  @deprecated
  String get ID => name;
  final String name;
  int channelCount = 0;
  bool inTransition = false;
  bool paused = true;
  bool registered = false;

  /**
   *
   */
  Peer(this.name);

  /**
   *
   */
  Peer.fromMap(Map map)
      : name = map[Key.name],
        registered = map[Key.registered],
        inTransition = map[Key.inTransition],
        paused = map[Key.paused],
        channelCount = map[Key.activeChannels];

  /**
   *
   */
  Map toJson() => {
        Key.ID: name,
        Key.name: name,
        Key.inTransition: inTransition,
        Key.paused: paused,
        Key.registered: registered,
        Key.activeChannels: channelCount
      };

  /**
   *
   */
  static Peer decode(Map map) => new Peer.fromMap(map);

  /**
   *
   */
  @override
  String toString() => '${this.ID}, registered:${this.registered}';
}
