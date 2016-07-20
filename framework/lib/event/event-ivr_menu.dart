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
 *
 */
class IvrMenuChange implements Event {
  @override
  final DateTime timestamp;

  @override
  String get eventName => Key._ivrMenuChange;

  bool get isCreate => state == Change.created;
  bool get isUpdate => state == Change.updated;
  bool get isDelete => state == Change.deleted;

  final String menuName;
  final int modifierUid;
  final String state;

  /**
   *
   */
  IvrMenuChange._internal(this.menuName, this.modifierUid, this.state)
      : timestamp = new DateTime.now();

  /*
   *
   */
  factory IvrMenuChange.create(String menuName, int modifierUid) =>
      new IvrMenuChange._internal(menuName, modifierUid, Change.created);

  /**
   *
   */
  factory IvrMenuChange.update(String menuName, int modifierUid) =>
      new IvrMenuChange._internal(menuName, modifierUid, Change.updated);

  /**
   *
   */
  factory IvrMenuChange.delete(String menuName, int modifierUid) =>
      new IvrMenuChange._internal(menuName, modifierUid, Change.deleted);

  /**
   *
   */
  @override
  String toString() => toJson().toString();

  /**
   *
   */
  @override
  Map toJson() => {
        Key.event: eventName,
        Key.timestamp: util.dateTimeToUnixTimestamp(timestamp),
        Key.modifierUid: modifierUid,
        Key._menuName: menuName,
        Key.state: this.state
      };

  /**
   *
   */
  IvrMenuChange.fromMap(Map map)
      : modifierUid = map[Key.modifierUid],
        menuName = map[Key._menuName],
        state = map[Key.state],
        timestamp = util.unixTimestampToDateTime(map[Key.timestamp]);
}
