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

class ReceptionChange implements Event {
  final DateTime timestamp;

  String get eventName => Key.receptionChange;

  final int rid;
  int modifierUid;
  final String state;

  /**
   *
   */
  ReceptionChange.created(this.rid, this.modifierUid)
      : this.state = Change.created,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  ReceptionChange.updated(this.rid, this.modifierUid)
      : this.state = Change.updated,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  ReceptionChange.deleted(this.rid, this.modifierUid)
      : this.state = Change.deleted,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  Map toJson() {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.receptionID: this.rid,
      Key.state: this.state,
      Key.modifierUid: modifierUid
    };

    template[this.eventName] = body;

    return template;
  }

  /**
   *
   */
  String toString() => toJson().toString();

  /**
   *
   */
  ReceptionChange.fromMap(Map map)
      : this.rid = map[Key.receptionChange][Key.receptionID],
        this.state = map[Key.receptionChange][Key.state],
        this.modifierUid = map[Key.receptionChange][Key.modifierUid],
        this.timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);
}
