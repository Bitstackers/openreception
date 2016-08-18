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
 * Event that spawns whenever a user changes its call-handling state.
 */
class UserState implements Event {
  @override
  final DateTime timestamp;

  @override
  final String eventName = _Key._userState;

  final model.UserStatus status;

  UserState(model.UserStatus this.status) : this.timestamp = new DateTime.now();

  @override
  String toString() => '$timestamp-$eventName $status';

  @override
  Map toJson() => {
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._uid: status.userId,
        _Key._paused: status.paused
      };

  UserState.fromMap(Map map)
      : this.status = new model.UserStatus()
          ..userId = map[_Key._uid]
          ..paused = map[_Key._paused],
        this.timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
