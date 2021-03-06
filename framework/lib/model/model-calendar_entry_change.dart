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

part of orf.model;

class CalendarChange implements ObjectChange {
  @override
  final ChangeType changeType;
  @override
  final ObjectType objectType = ObjectType.calendar;
  final int eid;

  CalendarChange(this.changeType, this.eid);

  factory CalendarChange.fromJson(Map<String, dynamic> map) =>
      new CalendarChange(changeTypeFromString(map[key.change]), map[key.eid]);

  @deprecated
  static CalendarChange decode(Map<String, dynamic> map) =>
      new CalendarChange.fromJson(map);

  /// Serization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.type: objectTypeToString(objectType),
        key.change: changeTypeToString(changeType),
        key.eid: eid
      };
}
