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
 * Model class representing a change in a [CalendarEntry]. May be serialized
 * and sent via a notification socket.
 */
class CalendarChange implements Event {
  @override
  final DateTime timestamp;

  @override
  String get eventName => _Key._calendarChange;

  final int eid;
  final int modifierUid;
  final model.Owner owner;
  final String state;

  bool get created => state == Change.created;
  bool get updated => state == Change.updated;
  bool get deleted => state == Change.deleted;

  /**
   *
   */
  CalendarChange.create(this.eid, this.owner, this.modifierUid)
      : timestamp = new DateTime.now(),
        state = Change.created;

  /**
   *
   */
  CalendarChange.update(this.eid, this.owner, this.modifierUid)
      : timestamp = new DateTime.now(),
        state = Change.updated;
  /**
   *
   */
  CalendarChange.delete(this.eid, this.owner, this.modifierUid)
      : timestamp = new DateTime.now(),
        state = Change.deleted;

  /**
   *
   */
  @override
  Map toJson() => {
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._eid: eid,
        _Key._owner: owner.toJson(),
        _Key._modifierUid: modifierUid,
        _Key._state: state
      };

  /**
   *
   */
  @override
  String toString() => this.toJson().toString();

  /**
   *
   */
  factory CalendarChange.fromMap(Map map) {
    int eid;
    int modifierUid;
    String state;
    final DateTime timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
    model.Owner owner = new model.Owner();

    /// Old-style object.
    if (map.containsKey(_Key._calendarChange)) {
      eid = map[_Key._calendarChange][_Key._eid];
      modifierUid = map[_Key._calendarChange][_Key._modifierUid];
      state = map[_Key._calendarChange][_Key._state];

      final int rid = map[_Key._calendarChange]['rid'];
      final int cid = map[_Key._calendarChange]['cid'];
      if (rid != 0 && rid != null) {
        owner = new model.OwningReception(rid);
      } else if (cid != 0 && cid != null) {
        owner = new model.OwningContact(cid);
      }
    } else {
      eid = map[_Key._eid];
      modifierUid = map[_Key._modifierUid];
      state = map[_Key._state];
      owner = new model.Owner.parse(map[_Key._owner]);
    }

    return new CalendarChange._internal(
        eid, owner, modifierUid, state, timestamp);
  }

  CalendarChange._internal(
      this.eid, this.owner, this.modifierUid, this.state, this.timestamp);
}
