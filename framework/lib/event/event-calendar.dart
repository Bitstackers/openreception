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
  final DateTime timestamp;

  String get eventName => Key.calendarChange;

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
  Map toJson() => {
        Key.event: eventName,
        Key.timestamp: util.dateTimeToUnixTimestamp(timestamp),
        Key.entryID: eid,
        Key.owner: owner.toJson(),
        Key.modifierUid: modifierUid,
        Key.state: state
      };

  /**
   *
   */
  String toString() => this.toJson().toString();

  /**
   *
   */
  factory CalendarChange.fromMap(Map map) {
    int eid;
    int modifierUid;
    String state;
    final DateTime timestamp = util.unixTimestampToDateTime(map[Key.timestamp]);
    model.Owner owner = new model.Owner();

    /// Old-style object.
    if (map.containsKey(Key.calendarChange)) {
      eid = map[Key.calendarChange][Key.entryID];
      modifierUid = map[Key.calendarChange][Key.modifierUid];
      state = map[Key.calendarChange][Key.state];

      final int rid = map[Key.calendarChange]['rid'];
      final int cid = map[Key.calendarChange]['cid'];
      if (rid != 0 && rid != null) {
        owner = new model.OwningReception(rid);
      } else if (cid != 0 && cid != null) {
        owner = new model.OwningContact(cid);
      }
    } else {
      eid = map[Key.entryID];
      modifierUid = map[Key.modifierUid];
      state = map[Key.state];
      owner = new model.Owner.parse(map[Key.owner]);
    }

    return new CalendarChange._internal(
        eid, owner, modifierUid, state, timestamp);
  }

  CalendarChange._internal(
      this.eid, this.owner, this.modifierUid, this.state, this.timestamp);
}
