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
  Map toJson() {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.entryID: eid,
      Key.owner: owner.toJson(),
      Key.modifierUid: modifierUid,
      Key.state: state
    };

    template[Key.calendarChange] = body;

    return template;
  }

  /**
   *
   */
  String toString() => this.toJson().toString();

  /**
   *
   */
  CalendarChange.fromMap(Map map)
      : eid = map[Key.calendarChange][Key.entryID],
        modifierUid = map[Key.calendarChange][Key.modifierUid],
        owner = new model.Owner.parse(map[Key.calendarChange][Key.owner]),
        state = map[Key.calendarChange][Key.state],
        timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);
}
