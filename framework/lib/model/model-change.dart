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
enum ObjectType {
  user,
  calendar,
  reception,
  contact,
  receptionAttribute,
  message
}

const Map<ObjectType, String> _objectTypeToString = const {
  ObjectType.user: Key.user,
  ObjectType.calendar: Key.calendar,
  ObjectType.reception: Key.reception,
  ObjectType.contact: Key.contact,
  ObjectType.receptionAttribute: Key.receptionAttributes,
  ObjectType.message: Key.message
};

const Map<String, ObjectType> _objectTypeFromString = const {
  Key.user: ObjectType.user,
  Key.calendar: ObjectType.calendar,
  Key.reception: ObjectType.reception,
  Key.contact: ObjectType.contact,
  Key.receptionAttributes: ObjectType.receptionAttribute,
  Key.message: ObjectType.message
};

String objectTypeToString(ObjectType ct) => _objectTypeToString.containsKey(ct)
    ? _objectTypeToString[ct]
    : throw new ArgumentError('Unknown ObjectType $ct');

ObjectType objectTypeFromString(String str) =>
    _objectTypeFromString.containsKey(str)
        ? _objectTypeFromString[str]
        : throw new ArgumentError('Unknown ObjectType $str');

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

abstract class ObjectChange {
  ChangeType get changeType;
  ObjectType get objectType;

  /**
   *
   */
  Map toJson();
}

/**
 * Class representing a historic change, by a [User].
 */
class Commit {
  DateTime changedAt;
  String authorIdentity;
  String commitHash;
  int uid = User.noId;
  List<ObjectChange> changes = [];

  /**
   * Default constructor.
   */
  Commit();

  /**
   * Deserializing constructor.
   */
  Commit.fromMap(Map map)
      : changes = new List<CalendarChange>.from(
            (map[Key.changes] as Iterable).map(CalendarChange.decode)),
        authorIdentity = map[Key.identity],
        changedAt = Util.unixTimestampToDateTime(map[Key.updatedAt]),
        commitHash = map[Key.commitHash],
        uid = map[Key.uid];

  /**
   * Decoding factory.
   */
  static Commit decode(Map map) => new Commit.fromMap(map);

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

/**
 *
 */
class IvrChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.user;
  final String menuName;

  /**
   *
   */
  IvrChange(this.changeType, this.menuName);

  /**
   *
   */
  static IvrChange decode(Map map) =>
      new IvrChange(changeTypeFromString(map[Key.change]), map[Key.name]);

  /**
   *
   */
  IvrChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[Key.change]),
        menuName = map[Key.name];

  /**
   *
   */
  Map toJson() => {
        Key.change: changeTypeToString(changeType),
        Key.type: objectTypeToString(objectType),
        Key.name: menuName
      };
}

/**
 * Class representing a historic change of a user object, effectuated
 * by a [User].
 */
class UserCommit implements Commit {
  DateTime changedAt;
  String authorIdentity;
  String commitHash;
  int uid = User.noId;
  List<UserChange> changes = [];

  /**
   * Default constructor.
   */
  UserCommit();

  /**
   * Deserializing constructor.
   */
  UserCommit.fromMap(Map map)
      : changes = new List<UserChange>.from(
            (map[Key.changes] as Iterable).map(UserChange.decode)),
        authorIdentity = map[Key.identity],
        changedAt = Util.unixTimestampToDateTime(map[Key.updatedAt]),
        commitHash = map[Key.commitHash],
        uid = map[Key.uid];

  /**
   * Decoding factory.
   */
  static UserCommit decode(Map map) => new UserCommit.fromMap(map);

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
