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

part of orf.event;

///Event that spawns every time a client opens or closes a connection.
class ClientConnectionState implements Event {
  @override
  final DateTime timestamp;

  /// The client connection that was changed.
  final model.ClientConnection conn;
  @override
  final String eventName = _Key._connectionState;

  /// Create a new [ClientConnectionState] for the [model.ClientConnection] conn.
  ClientConnectionState(this.conn) : timestamp = new DateTime.now();

  /// Create a new [ClientConnectionState] object from serialized data stored
  /// in [map].
  ClientConnectionState.fromJson(Map<String, dynamic> map)
      : conn = new model.ClientConnection.fromJson(
            map[_Key._state] as Map<String, dynamic>),
        timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);

  /// Returns an umodifiable map representation of the object, suitable for
  /// serialization.
  @override
  Map<String, dynamic> toJson() =>
      new Map<String, dynamic>.unmodifiable(<String, dynamic>{
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._state: conn
      });

  /// Returns a brief string-represented summary of the event, suitable for
  /// logging or debugging purposes.
  @override
  String toString() => '$timestamp-$eventName uid:${conn.userID}, '
      'connections:${conn.connectionCount}';
}
