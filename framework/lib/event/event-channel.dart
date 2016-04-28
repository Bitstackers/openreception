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

class ChannelState implements Event {
  final DateTime timestamp;
  final String eventName = Key.channelState;
  final String channelUuid;

  Map toJson() => EventTemplate.channel(this);

  String toString() => toJson().toString();

  ChannelState(String uuid)
      : channelUuid = uuid,
        timestamp = new DateTime.now();

  ChannelState.fromMap(Map map)
      : channelUuid = map[Key.channel][Key.id],
        timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);
}
