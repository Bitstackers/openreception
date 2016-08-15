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

class ReceptionChange implements Event {
  @override
  final DateTime timestamp;

  @override
  String get eventName => _Key._receptionChange;

  final int rid;
  int modifierUid;
  final String state;

  bool get created => state == Change.created;
  bool get updated => state == Change.updated;
  bool get deleted => state == Change.deleted;

  /**
   *
   */
  ReceptionChange.create(this.rid, this.modifierUid)
      : this.state = Change.created,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  ReceptionChange.update(this.rid, this.modifierUid)
      : this.state = Change.updated,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  ReceptionChange.delete(this.rid, this.modifierUid)
      : this.state = Change.deleted,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  @override
  Map toJson() {
    Map template = EventTemplate._rootElement(this);

    Map body = {
      _Key._receptionID: this.rid,
      _Key._state: this.state,
      _Key._modifierUid: modifierUid
    };

    template[this.eventName] = body;

    return template;
  }

  /**
   *
   */
  @override
  String toString() => toJson().toString();

  /**
   *
   */
  ReceptionChange.fromMap(Map map)
      : rid = map[_Key._receptionChange][_Key._receptionID],
        state = map[_Key._receptionChange][_Key._state],
        modifierUid = map[_Key._receptionChange][_Key._modifierUid],
        timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
