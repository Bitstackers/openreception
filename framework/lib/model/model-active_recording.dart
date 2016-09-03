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

/// Model class of a recording currently active in the system.
class ActiveRecording {
  /// The name of the agent channel currently being recorded.
  final String agentChannel;

  /// The filesystem path to the recording file.
  final String path;

  /// The time the recording was started.
  final DateTime started;

  /// Default constructor. Requires [agentChannel] and [path] to be provided
  ActiveRecording(this.agentChannel, this.path) : started = new DateTime.now();

  /// Deserializing constructor.
  ActiveRecording.fromMap(Map map)
      : agentChannel = map[key.agentChannel],
        path = map[key.path],
        started = util.unixTimestampToDateTime(map[key.started]);

  /// Decoding factory.
  static ActiveRecording decode(Map map) => new ActiveRecording.fromMap(map);

  /// Serialization function.
  Map toJson() => {
        key.agentChannel: agentChannel,
        key.path: path,
        key.started: util.dateTimeToUnixTimestamp(started)
      };
}
