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

/// Model class representing a change in a persistent [model.CalendarEntry]
/// object. May be serialized and sent via a notification socket.
class CalendarChange implements Event {
  @override
  final DateTime timestamp;

  @override
  final String eventName = _Key._calendarChange;

  /// The calendar entry id.
  final int eid;

  /// The uid of the user modifying the calendar entry.
  final int modifierUid;

  /// The current owner of the calendar entry.
  final model.Owner owner;

  /// The modification state. Must be one of the valid [Change] values.
  final String state;

  /// Create a new creation event.
  CalendarChange.create(this.eid, this.owner, this.modifierUid)
      : timestamp = new DateTime.now(),
        state = Change.created;

  /// Create a new update event.
  CalendarChange.update(this.eid, this.owner, this.modifierUid)
      : timestamp = new DateTime.now(),
        state = Change.updated;

  /// Create a new deletion event.
  CalendarChange.delete(this.eid, this.owner, this.modifierUid)
      : timestamp = new DateTime.now(),
        state = Change.deleted;

  /// Create a new [CalendarChange] object from serialized data stored in [map].
  factory CalendarChange.fromMap(Map<String, dynamic> map) {
    int eid;
    int modifierUid;
    String state;
    final DateTime timestamp =
        util.unixTimestampToDateTime(map[_Key._timestamp]);
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

  /// Internal constructor.
  CalendarChange._internal(
      this.eid, this.owner, this.modifierUid, this.state, this.timestamp);

  /// Determines if the object signifies a creation.
  bool get isCreate => state == Change.created;

  /// Determines if the object signifies an update.
  bool get isUpdate => state == Change.updated;

  /// Determines if the object signifies a deletion.
  bool get isDelete => state == Change.deleted;

  /// Returns an umodifiable map representation of the object, suitable for
  /// serialization.
  @override
  Map<String, dynamic> toJson() =>
      new Map<String, dynamic>.unmodifiable(<String, dynamic>{
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._eid: eid,
        _Key._owner: owner.toJson(),
        _Key._modifierUid: modifierUid,
        _Key._state: state
      });

  /// Returns a brief string-represented summary of the event, suitable for
  /// logging or debugging purposes.
  @override
  String toString() => '$timestamp-$eventName $state '
      'modifier:$modifierUid,eid:$eid,';
}
