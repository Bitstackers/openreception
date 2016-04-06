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

/**
 *
 */
enum ChangeType { add, delete, modify }

String changeTypeToString(ChangeType ct) => _changeTypeToString.containsKey(ct)
    ? _changeTypeToString[ct]
    : throw new ArgumentError('Unknown ChangeType $ct');

ChangeType changeTypeFromString(String str) =>
    _changeTypeFromString.containsKey(str)
        ? _changeTypeFromString[str]
        : throw new ArgumentError('Unknown ChangeType $str');

const Map<ChangeType, String> _changeTypeToString = const {
  ChangeType.add: 'A',
  ChangeType.modify: 'M',
  ChangeType.delete: 'D'
};

const Map<String, ChangeType> _changeTypeFromString = const {
  'A': ChangeType.add,
  'M': ChangeType.modify,
  'D': ChangeType.delete
};

class CalendarChange {
  final ChangeType changeType;
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
