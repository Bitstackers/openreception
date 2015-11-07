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
class ActiveRecording {
  final String agentChannel;
  @deprecated
  String get uuid => agentChannel;
  final String path;
  final DateTime started;

  /**
   *
   */
  ActiveRecording(this.agentChannel, this.path)
      : started = new DateTime.now();

  /**
   *
   */
  static ActiveRecording decode(Map map) => new ActiveRecording.fromMap(map);

  /**
   *
   */
  ActiveRecording.fromMap(Map map) :
    agentChannel = map[Key.agentChannel],
    path = map[Key.path],
    started = Util.unixTimestampToDateTime(map[Key.started]);

  /**
   *
   */
  Map toJson() => {
    Key.agentChannel : agentChannel,
    Key.path : path,
    Key.started : Util.dateTimeToUnixTimestamp(started)
  };
}