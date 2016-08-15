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

/**
 * Event that spawns every time a client opens or closes a connection.
 */
class ClientConnectionState implements Event {
  @override
  final DateTime timestamp;

  final model.ClientConnection conn;
  @override
  String get eventName => _Key._connectionState;

  ClientConnectionState(model.ClientConnection this.conn)
      : timestamp = new DateTime.now();

  @override
  Map toJson() => EventTemplate.connection(this);
  @override
  String toString() => toJson().toString();

  ClientConnectionState.fromMap(Map map)
      : conn = new model.ClientConnection.fromMap(map[_Key._state]),
        timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
