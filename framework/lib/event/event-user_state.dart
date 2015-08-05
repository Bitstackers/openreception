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

/**
 * Event that spawns whenever a user changes its call-handling state.
 */
class UserState implements Event {

  final DateTime timestamp;
  final String eventName = Key.userState;

  final UserStatus status;

  UserState(UserStatus this.status) : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.userState(this);

  UserState.fromMap(Map map)
      : this.status = new UserStatus.fromMap(map),
        this.timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);

}
