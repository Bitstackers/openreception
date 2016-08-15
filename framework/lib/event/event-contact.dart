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
class ContactChange implements Event {
  @override
  final DateTime timestamp;

  @override
  String get eventName => _Key._contactChange;

  final int cid;
  final int modifierUid;
  final String state;

  bool get created => state == Change.created;
  bool get updated => state == Change.updated;
  bool get deleted => state == Change.deleted;

  /**
   *
   */
  ContactChange.create(this.cid, [int uid])
      : timestamp = new DateTime.now(),
        state = Change.created,
        modifierUid = uid != null ? uid : model.User.noId;

  /**
   *
   */
  ContactChange.update(this.cid, [int uid])
      : timestamp = new DateTime.now(),
        state = Change.updated,
        modifierUid = uid != null ? uid : model.User.noId;

  /**
   *
   */
  ContactChange.delete(this.cid, [int uid])
      : timestamp = new DateTime.now(),
        state = Change.deleted,
        modifierUid = uid != null ? uid : model.User.noId;

  /**
   * JSON serialization function.
   */
  @override
  Map toJson() {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      _Key._contactID: cid,
      _Key._state: state,
      _Key._modifierUid: modifierUid
    };

    template[_Key._calendarChange] = body;

    return template;
  }

  /**
   * String representation
   */
  @override
  String toString() => this.toJson().toString();

  /**
   * Deserializing constructor.
   */
  ContactChange.fromMap(Map map)
      : cid = map[_Key._calendarChange][_Key._contactID],
        modifierUid = map[_Key._calendarChange][_Key._modifierUid],
        state = map[_Key._calendarChange][_Key._state],
        timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
