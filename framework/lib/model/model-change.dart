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

part of openreception.framework.model;

/**
 * Diffent object types available for storage, Matches model classes that
 * needs persistent storage.
 */
enum ObjectType {
  user,
  calendar,
  reception,
  organization,
  contact,
  receptionAttribute,
  dialplan,
  ivrMenu,
  message
}

/// Map with serialization keys and values
const Map<ObjectType, String> _objectTypeToString = const {
  ObjectType.user: key.user,
  ObjectType.calendar: key.calendar,
  ObjectType.reception: key.reception,
  ObjectType.contact: key.contact,
  ObjectType.receptionAttribute: key.receptionAttributes,
  ObjectType.message: key.message,
  ObjectType.organization: key.organization,
  ObjectType.dialplan: key.dialplan,
  ObjectType.ivrMenu: key.ivrMenu
};

/// Map with deserialization keys and values
const Map<String, ObjectType> _objectTypeFromString = const {
  key.user: ObjectType.user,
  key.calendar: ObjectType.calendar,
  key.reception: ObjectType.reception,
  key.contact: ObjectType.contact,
  key.receptionAttributes: ObjectType.receptionAttribute,
  key.message: ObjectType.message,
  key.organization: ObjectType.organization,
  key.dialplan: ObjectType.dialplan,
  key.ivrMenu: ObjectType.ivrMenu
};

/**
 * Convert an [ObjectType] to a [String]. Suitable for serialization.
 */
String objectTypeToString(ObjectType ct) => _objectTypeToString.containsKey(ct)
    ? _objectTypeToString[ct]
    : throw new ArgumentError('Unknown ObjectType $ct');

/**
 * Convert a [String] to an [ObjectType]. Suitable for deserialization.
 */
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

  static ObjectChange decode(Map map) {
    final ObjectType objectType = objectTypeFromString(map[key.type]);

    switch (objectType) {
      case ObjectType.calendar:
        return CalendarChange.decode(map);
      case ObjectType.contact:
        return ContactChange.decode(map);
      case ObjectType.dialplan:
        return ReceptionDialplanChange.decode(map);
      case ObjectType.ivrMenu:
        return IvrChange.decode(map);
      case ObjectType.message:
        return MessageChange.decode(map);
      case ObjectType.reception:
        return ReceptionChange.decode(map);
      case ObjectType.receptionAttribute:
        return ReceptionAttributeChange.decode(map);
      case ObjectType.user:
        return UserChange.decode(map);
      case ObjectType.organization:
        return OrganizationChange.decode(map);
    }
  }

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
      : changes = new List<ObjectChange>.from(
            (map[key.changes] as Iterable).map(ObjectChange.decode)),
        authorIdentity = map[key.identity],
        changedAt = util.unixTimestampToDateTime(map[key.updatedAt]),
        commitHash = map[key.commitHash],
        uid = map[key.uid];

  /**
   * Decoding factory.
   */
  static Commit decode(Map map) => new Commit.fromMap(map);

  /**
   * Returns a map representation of the object.
   * Suitable for serialization.
   */
  Map toJson() => {
        key.identity: authorIdentity,
        key.updatedAt: util.dateTimeToUnixTimestamp(changedAt),
        key.commitHash: commitHash,
        key.uid: uid,
        key.changes: new List<Map>.from(changes.map((c) => c.toJson()))
      };
}

/**
 *
 */
class IvrChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.ivrMenu;
  final String menuName;

  /**
   *
   */
  IvrChange(this.changeType, this.menuName);

  /**
   *
   */
  static IvrChange decode(Map map) =>
      new IvrChange(changeTypeFromString(map[key.change]), map[key.name]);

  /**
   *
   */
  IvrChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[key.change]),
        menuName = map[key.name];

  /**
   *
   */
  Map toJson() => {
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.name: menuName
      };
}

/**
 *
 */
class ReceptionDialplanChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.dialplan;
  final String extension;

  /**
   *
   */
  ReceptionDialplanChange(this.changeType, this.extension);

  /**
   *
   */
  static ReceptionDialplanChange decode(Map map) => new ReceptionDialplanChange(
      changeTypeFromString(map[key.change]), map[key.name]);

  /**
   *
   */
  ReceptionDialplanChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[key.change]),
        extension = map[key.name];

  /**
   *
   */
  Map toJson() => {
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.name: extension
      };
}

/**
 *
 */
class MessageChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.message;
  final int mid;

  /**
   *
   */
  MessageChange(this.changeType, this.mid);

  /**
   *
   */
  static MessageChange decode(Map map) => new MessageChange.fromJson(map);

  /**
   *
   */
  MessageChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[key.change]),
        mid = map[key.mid];

  /**
   *
   */
  Map toJson() => {
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.mid: mid
      };
}

/**
 *
 */
class OrganizationChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.organization;
  final int oid;

  /**
   *
   */
  OrganizationChange(this.changeType, this.oid);

  /**
   *
   */
  static OrganizationChange decode(Map map) =>
      new OrganizationChange.fromJson(map);

  /**
   *
   */
  OrganizationChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[key.change]),
        oid = map[key.mid];

  /**
   *
   */
  Map toJson() => {
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.mid: oid
      };
}

/**
 *
 */
class ReceptionChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.reception;
  final int rid;

  /**
   *
   */
  ReceptionChange(this.changeType, this.rid);

  /**
   *
   */
  static ReceptionChange decode(Map map) => new ReceptionChange.fromJson(map);

  /**
   *
   */
  ReceptionChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[key.change]),
        rid = map[key.mid];

  /**
   *
   */
  Map toJson() => {
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.mid: rid
      };
}
