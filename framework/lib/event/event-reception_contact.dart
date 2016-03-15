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

class ReceptionData implements Event {
  final DateTime timestamp;

  String get eventName => Key.receptionData;

  final int rid;
  final int cid;
  final int modifierUid;
  final String state;

  bool get created => state == Change.created;
  bool get updated => state == Change.updated;
  bool get deleted => state == Change.deleted;
  /**
   *
   */
  ReceptionData.create(this.cid, this.rid, this.modifierUid)
      : this.timestamp = new DateTime.now(),
        state = Change.created;

  /**
   *
   */
  ReceptionData.update(this.cid, this.rid, this.modifierUid)
      : this.timestamp = new DateTime.now(),
        state = Change.updated;

  /**
   *
   */
  ReceptionData.delete(this.cid, this.rid, this.modifierUid)
      : this.timestamp = new DateTime.now(),
        state = Change.deleted;

  /**
   *
   */
  Map toJson() {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      Key.contactID: cid,
      Key.receptionID: rid,
      Key.state: state,
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
  ReceptionData.fromMap(Map map)
      : cid = map[Key.receptionData][Key.contactID],
        rid = map[Key.receptionData][Key.receptionID],
        state = map[Key.receptionData][Key.state],
        modifierUid = map[Key.receptionData][Key.modifierUid],
        timestamp = Util.unixTimestampToDateTime(map[Key.timestamp]);
}
