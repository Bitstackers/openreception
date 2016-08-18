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

class UserChange implements Event {
  @override
  final DateTime timestamp;

  @override
  String get eventName => _Key._userChange;

  final int uid;
  final int modifierUid;
  final String state;

  bool get created => state == Change.created;
  bool get updated => state == Change.updated;
  bool get deleted => state == Change.deleted;

  UserChange._internal(this.uid, this.state, this.modifierUid)
      : timestamp = new DateTime.now();

  factory UserChange.create(int userID, int changedBy) =>
      new UserChange._internal(userID, Change.created, changedBy);

  factory UserChange.update(int userID, int changedBy) =>
      new UserChange._internal(userID, Change.updated, changedBy);

  factory UserChange.delete(int userID, int changedBy) =>
      new UserChange._internal(userID, Change.deleted, changedBy);

  @override
  Map toJson() => {
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._modifierUid: modifierUid,
        _Key._userChange: {
          _Key._modifierUid: uid,
          _Key._state: state,
          _Key._changedBy: modifierUid
        }
      };

  /**
   *
   */
  @override
  String toString() => 'UserChange, uid:$uid, state:$state';

  /**
  *
  */
  UserChange.fromMap(Map map)
      : uid = map[_Key._userChange][_Key._modifierUid],
        state = map[_Key._userChange][_Key._state],
        modifierUid = map[_Key._userChange][_Key._changedBy],
        timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
