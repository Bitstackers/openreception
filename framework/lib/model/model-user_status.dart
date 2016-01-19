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
 * 'Enum' type representing the different states of a user, in the context of
 * being able to pickup calls. As an example; a user in the the 'idle' state
 * may pick up a call, while a user that is 'paused' may not.
 * UserState does not imply connectivity, so other states such as [PeerState]
 * or [ClientConnection] should always also be checked before detemining wheter
 * a user is connectable or not.
 */
abstract class UserState {
  static const Ready = 'ready';
  static const Paused = 'paused';
}

class UserStatus {
  bool paused = true;
  int userID = User.noID;

  Map toJson() => this.asMap;

  UserStatus();

  static UserStatus decode(Map map) => new UserStatus.fromMap(map);

  UserStatus.fromMap(Map map)
      : userID = map[Key.id],
        paused = map[Key.paused];

  Map get asMap => {Key.id: userID, Key.paused: paused};
}
