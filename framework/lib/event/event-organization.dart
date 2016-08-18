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

class OrganizationChange implements Event {
  @override
  final DateTime timestamp;

  @override
  String get eventName => _Key._organizationChange;

  final int oid;
  final int modifierUid;
  final String state;

  bool get created => state == Change.created;
  bool get updated => state == Change.updated;
  bool get deleted => state == Change.deleted;
  /**
   *
   */
  OrganizationChange.create(this.oid, this.modifierUid)
      : this.state = Change.created,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  OrganizationChange.update(this.oid, this.modifierUid)
      : this.state = Change.updated,
        this.timestamp = new DateTime.now();

  /**
   *
   */
  OrganizationChange.delete(this.oid, this.modifierUid)
      : this.state = Change.deleted,
        this.timestamp = new DateTime.now();

  @override
  Map toJson() => {
        _Key._event: eventName,
        _Key._timestamp: util.dateTimeToUnixTimestamp(timestamp),
        _Key._modifierUid: modifierUid,
        _Key._organizationChange: {
          _Key._oid: this.oid,
          _Key._state: this.state,
          _Key._modifierUid: modifierUid
        }
      };

  @override
  String toString() => this.toJson().toString();

  OrganizationChange.fromMap(Map map)
      : this.oid = map[_Key._organizationChange][_Key._oid],
        this.state = map[_Key._organizationChange][_Key._state],
        this.modifierUid = map[_Key._organizationChange][_Key._modifierUid],
        this.timestamp = util.unixTimestampToDateTime(map[_Key._timestamp]);
}
