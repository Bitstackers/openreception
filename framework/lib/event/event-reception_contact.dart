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

class ReceptionData implements Event {
  @override
  final DateTime timestamp;

  @override
  String get eventName => _Key._receptionData;

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

  @override
  Map toJson() => {
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._modifierUid: modifierUid,
        _Key._receptionData: {
          _Key._contactID: cid,
          _Key._receptionID: rid,
          _Key._state: state,
          _Key._modifierUid: modifierUid
        }
      };

  /**
   *
   */
  @override
  String toString() => toJson().toString();

  /**
   *
   */
  ReceptionData.fromMap(Map map)
      : cid = map[_Key._receptionData][_Key._contactID],
        rid = map[_Key._receptionData][_Key._receptionID],
        state = map[_Key._receptionData][_Key._state],
        modifierUid = map[_Key._receptionData][_Key._modifierUid],
        timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
