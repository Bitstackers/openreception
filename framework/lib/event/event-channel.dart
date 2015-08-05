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

part of openreception.event;

class ChannelState implements Event {
  final DateTime timestamp;
  final String   eventName = Key.channelState;
  final String   channelID;

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.channel (this);

  ChannelState(String channelID) :
      this.channelID = channelID,
      this.timestamp = new DateTime.now();

  ChannelState.fromMap (Map map) :
    this.channelID = map[Key.channel][Key.ID],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}


