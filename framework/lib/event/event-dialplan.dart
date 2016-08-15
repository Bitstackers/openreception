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
class DialplanChange implements Event {
  @override
  final DateTime timestamp;

  @override
  String get eventName => _Key._dialplanChange;

  bool get isCreate => state == Change.created;
  bool get isUpdate => state == Change.updated;
  bool get isDelete => state == Change.deleted;

  final String extension;
  final int modifierUid;
  final String state;

  /**
   *
   */
  DialplanChange._internal(this.extension, this.modifierUid, this.state)
      : timestamp = new DateTime.now();

  /*
   *
   */
  factory DialplanChange.create(String extension, int modifierUid) =>
      new DialplanChange._internal(extension, modifierUid, Change.created);

  /**
   *
   */
  factory DialplanChange.update(String extension, int modifierUid) =>
      new DialplanChange._internal(extension, modifierUid, Change.updated);

  /**
   *
   */
  factory DialplanChange.delete(String extension, int modifierUid) =>
      new DialplanChange._internal(extension, modifierUid, Change.deleted);

  /**
   *
   *
   */
  @override
  String toString() => toJson().toString();

  /**
   *
   */
  @override
  Map toJson() => {
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._modifierUid: modifierUid,
        _Key._extension: extension,
        _Key._state: this.state
      };

  /**
   *
   */
  DialplanChange.fromMap(Map map)
      : modifierUid = map[_Key._modifierUid],
        extension = map[_Key._extension],
        state = map[_Key._state],
        timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
