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

part of openreception.model;

class CalendarChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.calendar;
  final int eid;
  final Owner owner;

  /**
   *
   */
  CalendarChange(this.changeType, this.eid, this.owner);

  /**
   *
   */
  static CalendarChange decode(Map map) => new CalendarChange(
      changeTypeFromString(map[Key.change]),
      map[Key.eid],
      new Owner.parse(map[Key.owner]));

  /**
   *
   */
  Map toJson() => {
        Key.change: changeTypeToString(changeType),
        Key.eid: eid,
        Key.owner: owner.toJson()
      };
}

/**
 * Class representing a historic change, by a [User].
 */
class CalendarCommit {
  DateTime changedAt;
  String authorIdentity;
  String commitHash;
  int uid = User.noId;
  List<CalendarChange> changes = [];

  /**
   * Default constructor.
   */
  CalendarCommit();

  /**
   * Deserializing constructor.
   */
  CalendarCommit.fromMap(Map map)
      : changes = new List<CalendarChange>.from(
            (map[Key.changes] as Iterable).map(CalendarChange.decode)),
        authorIdentity = map[Key.identity],
        changedAt = Util.unixTimestampToDateTime(map[Key.updatedAt]),
        commitHash = map[Key.commitHash],
        uid = map[Key.uid];

  /**
   * Decoding factory.
   */
  static CalendarCommit decode(Map map) => new CalendarCommit.fromMap(map);

  /**
   * Returns a map representation of the object.
   * Suitable for serialization.
   */
  Map toJson() => {
        Key.identity: authorIdentity,
        Key.updatedAt: Util.dateTimeToUnixTimestamp(changedAt),
        Key.commitHash: commitHash,
        Key.uid: uid,
        Key.changes: new List<Map>.from(changes.map((c) => c.toJson()))
      };
}
