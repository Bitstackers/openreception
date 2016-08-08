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
 *
 */
class CalendarChangelogEntry implements ChangelogEntry {
  final UserReference modifier;
  final DateTime timestamp;
  final CalendarEntry entry;
  final ChangeType changeType;

  /**
   *
   */
  CalendarChangelogEntry.create(this.modifier, this.entry)
      : changeType = ChangeType.add,
        timestamp = new DateTime.now();

  CalendarChangelogEntry.update(this.modifier, this.entry)
      : changeType = ChangeType.modify,
        timestamp = new DateTime.now();

  CalendarChangelogEntry.delete(this.modifier, int eid)
      : changeType = ChangeType.delete,
        entry = new CalendarEntry.empty()..id = eid,
        timestamp = new DateTime.now();

  /**
   *
   */
  CalendarChangelogEntry.fromMap(Map map)
      : modifier = UserReference.decode(map['modifier']),
        entry = CalendarEntry.decode(map['entry']),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /**
   *
   */
  @override
  Map toJson() => {
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'entry': entry.toJson()
      };
}

/**
 *
 */
class ContactChangelogEntry implements ChangelogEntry {
  final UserReference modifier;
  final DateTime timestamp;
  final BaseContact contact;
  final ChangeType changeType;

  /**
   *
   */
  ContactChangelogEntry.create(this.modifier, this.contact)
      : changeType = ChangeType.add,
        timestamp = new DateTime.now();

  ContactChangelogEntry.update(this.modifier, this.contact)
      : changeType = ChangeType.modify,
        timestamp = new DateTime.now();

  ContactChangelogEntry.delete(this.modifier, int cid)
      : changeType = ChangeType.delete,
        contact = new BaseContact.empty()..id = cid,
        timestamp = new DateTime.now();

  /**
   *
   */
  ContactChangelogEntry.fromMap(Map map)
      : modifier = UserReference.decode(map['modifier']),
        contact = BaseContact.decode(map['contact']),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /**
   *
   */
  @override
  Map toJson() => {
        'change': changeTypeToString(changeType),
        'modifier': util.dateTimeToUnixTimestamp(timestamp),
        'user': modifier.toJson(),
        'contact': contact.toJson()
      };
}

/**
 *
 */
class ReceptionDataChangelogEntry implements ChangelogEntry {
  final UserReference modifier;
  final DateTime timestamp;
  final ReceptionAttributes attributes;
  final ChangeType changeType;

  /**
   *
   */
  ReceptionDataChangelogEntry.create(this.modifier, this.attributes)
      : changeType = ChangeType.add,
        timestamp = new DateTime.now();

  ReceptionDataChangelogEntry.update(this.modifier, this.attributes)
      : changeType = ChangeType.modify,
        timestamp = new DateTime.now();

  ReceptionDataChangelogEntry.delete(this.modifier, int cid, int rid)
      : changeType = ChangeType.delete,
        attributes = new ReceptionAttributes.empty()
          ..cid = cid
          ..receptionId = rid,
        timestamp = new DateTime.now();

  /**
   *
   */
  ReceptionDataChangelogEntry.fromMap(Map map)
      : modifier = UserReference.decode(map['modifier']),
        attributes = ReceptionAttributes.decode(map['attributes']),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /**
   *
   */
  @override
  Map toJson() => {
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'attributes': attributes.toJson()
      };
}

/**
 *
 */
class IvrChangelogEntry implements ChangelogEntry {
  final UserReference modifier;
  final DateTime timestamp;
  final IvrMenu menu;
  final ChangeType changeType;

  /**
   *
   */
  IvrChangelogEntry.create(this.modifier, this.menu)
      : changeType = ChangeType.add,
        timestamp = new DateTime.now();

  IvrChangelogEntry.update(this.modifier, this.menu)
      : changeType = ChangeType.modify,
        timestamp = new DateTime.now();

  IvrChangelogEntry.delete(this.modifier, String menuName)
      : changeType = ChangeType.delete,
        menu = new IvrMenu('', new Playback(''))..name = menuName,
        timestamp = new DateTime.now();

  /**
   *
   */
  IvrChangelogEntry.fromMap(Map map)
      : modifier = UserReference.decode(map['modifier']),
        menu = IvrMenu.decode(map['menu']),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /**
   *
   */
  @override
  Map toJson() => {
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'menu': menu.toJson()
      };
}

/**
 *
 */
class DialplanChangelogEntry implements ChangelogEntry {
  final UserReference modifier;
  final DateTime timestamp;
  final ReceptionDialplan dialplan;
  final ChangeType changeType;

  /**
   *
   */
  DialplanChangelogEntry.create(this.modifier, this.dialplan)
      : changeType = ChangeType.add,
        timestamp = new DateTime.now();

  DialplanChangelogEntry.update(this.modifier, this.dialplan)
      : changeType = ChangeType.modify,
        timestamp = new DateTime.now();

  DialplanChangelogEntry.delete(this.modifier, String extension)
      : changeType = ChangeType.delete,
        dialplan = new ReceptionDialplan()..extension = extension,
        timestamp = new DateTime.now();

  /**
   *
   */
  DialplanChangelogEntry.fromMap(Map map)
      : modifier = UserReference.decode(map['modifier']),
        dialplan = ReceptionDialplan.decode(map['dialplan']),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /**
   *
   */
  @override
  Map toJson() => {
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'dialplan': dialplan.toJson()
      };
}

/**
 *
 */
class ReceptionChangelogEntry implements ChangelogEntry {
  final UserReference modifier;
  final DateTime timestamp;
  final Reception reception;
  final ChangeType changeType;

  /**
   *
   */
  ReceptionChangelogEntry.create(this.modifier, this.reception)
      : changeType = ChangeType.add,
        timestamp = new DateTime.now();

  ReceptionChangelogEntry.update(this.modifier, this.reception)
      : changeType = ChangeType.modify,
        timestamp = new DateTime.now();

  ReceptionChangelogEntry.delete(this.modifier, int rid)
      : changeType = ChangeType.delete,
        reception = new Reception.empty()..id = rid,
        timestamp = new DateTime.now();

  /**
   *
   */
  ReceptionChangelogEntry.fromMap(Map map)
      : modifier = UserReference.decode(map['modifier']),
        reception = Reception.decode(map['reception']),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /**
   *
   */
  @override
  Map toJson() => {
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'reception': reception.toJson()
      };
}

/**
 *
 */
class OrganizationChangelogEntry implements ChangelogEntry {
  final UserReference modifier;
  final DateTime timestamp;
  final Organization organization;
  final ChangeType changeType;

  /**
   *
   */
  OrganizationChangelogEntry.create(this.modifier, this.organization)
      : changeType = ChangeType.add,
        timestamp = new DateTime.now();

  OrganizationChangelogEntry.update(this.modifier, this.organization)
      : changeType = ChangeType.modify,
        timestamp = new DateTime.now();

  OrganizationChangelogEntry.delete(this.modifier, int oid)
      : changeType = ChangeType.delete,
        organization = new Organization.empty()..id = oid,
        timestamp = new DateTime.now();

  /**
   *
   */
  OrganizationChangelogEntry.fromMap(Map map)
      : modifier = UserReference.decode(map['modifier']),
        organization = Organization.decode(map['organization']),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /**
   *
   */
  @override
  Map toJson() => {
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'organization': organization.toJson()
      };
}

/**
 *
 */
class UserChangelogEntry implements ChangelogEntry {
  final UserReference modifier;
  final DateTime timestamp;
  final User user;
  final ChangeType changeType;

  /**
   *
   */
  UserChangelogEntry.create(this.modifier, this.user)
      : changeType = ChangeType.add,
        timestamp = new DateTime.now();

  UserChangelogEntry.update(this.modifier, this.user)
      : changeType = ChangeType.modify,
        timestamp = new DateTime.now();

  UserChangelogEntry.delete(this.modifier, int uid)
      : changeType = ChangeType.delete,
        user = new User.empty()..id = uid,
        timestamp = new DateTime.now();

  /**
   *
   */
  UserChangelogEntry.fromMap(Map map)
      : modifier = UserReference.decode(map['modifier']),
        user = User.decode(map['user']),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /**
   *
   */
  @override
  Map toJson() => {
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'user': user.toJson()
      };
}

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

      default:
        throw new StateError('Undefined object type: $objectType');
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
  @override
  final ChangeType changeType;
  @override
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
  @override
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
  @override
  final ChangeType changeType;
  @override
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
  @override
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
  @override
  final ChangeType changeType;
  @override
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
  @override
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
  @override
  final ChangeType changeType;
  @override
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
  @override
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
  @override
  final ChangeType changeType;
  @override
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
  @override
  Map toJson() => {
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.mid: rid
      };
}
