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

part of openreception.framework.model;

/// [Peer] model class.
///
/// Used in the call-flow-control server to monitor the registration and
/// availability status of peers (phones).
class Peer {
  final String name;
  int channelCount = 0;
  bool inTransition = false;
  bool registered = false;

  /// Default constructor.
  Peer(this.name);

  /// Deserizaling constructor.
  Peer.fromMap(Map map)
      : name = map[key.name],
        registered = map[key.registered],
        inTransition = map[key.inTransition],
        channelCount = map[key.activeChannels];

  /// Serialization function.
  Map toJson() => {
        key.name: name,
        key.inTransition: inTransition,
        key.registered: registered,
        key.activeChannels: channelCount
      };

  /// Deserializing factory.
  static Peer decode(Map map) => new Peer.fromMap(map);

  /// Returns a string representation of the object.
  @override
  String toString() => '$name, registered:$registered';
}
