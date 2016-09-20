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

class CalendarChangelogEntry implements ChangelogEntry {
  @override
  final DateTime timestamp;

  @override
  final ChangeType changeType;

  @override
  final UserReference modifier;

  final CalendarEntry entry;

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

  CalendarChangelogEntry.fromJson(Map<String, dynamic> map)
      : modifier =
            UserReference.decode(map['modifier'] as Map<String, dynamic>),
        entry = CalendarEntry.decode(map['entry'] as Map<String, dynamic>),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'entry': entry.toJson()
      };
}

class ContactChangelogEntry implements ChangelogEntry {
  @override
  final DateTime timestamp;

  @override
  final ChangeType changeType;

  @override
  final UserReference modifier;

  final BaseContact contact;

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

  ContactChangelogEntry.fromJson(Map<String, dynamic> map)
      : modifier =
            UserReference.decode(map['modifier'] as Map<String, dynamic>),
        contact = BaseContact.decode(map['contact'] as Map<String, dynamic>),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'change': changeTypeToString(changeType),
        'modifier': util.dateTimeToUnixTimestamp(timestamp),
        'user': modifier.toJson(),
        'contact': contact.toJson()
      };
}

class ReceptionDataChangelogEntry implements ChangelogEntry {
  @override
  final DateTime timestamp;

  @override
  final ChangeType changeType;

  @override
  final UserReference modifier;

  final ReceptionAttributes attributes;

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

  ReceptionDataChangelogEntry.fromJson(Map<String, dynamic> map)
      : modifier =
            UserReference.decode(map['modifier'] as Map<String, dynamic>),
        attributes = ReceptionAttributes
            .decode(map['attributes'] as Map<String, dynamic>),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'attributes': attributes.toJson()
      };
}

class IvrChangelogEntry implements ChangelogEntry {
  @override
  final DateTime timestamp;

  @override
  final ChangeType changeType;

  @override
  final UserReference modifier;

  final IvrMenu menu;

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

  IvrChangelogEntry.fromJson(Map<String, dynamic> map)
      : modifier =
            UserReference.decode(map['modifier'] as Map<String, dynamic>),
        menu = IvrMenu.decode(map['menu'] as Map<String, dynamic>),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'menu': menu.toJson()
      };
}

class DialplanChangelogEntry implements ChangelogEntry {
  @override
  final DateTime timestamp;

  @override
  final ChangeType changeType;

  @override
  final UserReference modifier;

  final ReceptionDialplan dialplan;

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

  DialplanChangelogEntry.fromJson(Map<String, dynamic> map)
      : modifier =
            UserReference.decode(map['modifier'] as Map<String, dynamic>),
        dialplan =
            ReceptionDialplan.decode(map['dialplan'] as Map<String, dynamic>),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'dialplan': dialplan.toJson()
      };
}

class ReceptionChangelogEntry implements ChangelogEntry {
  @override
  final DateTime timestamp;

  @override
  final ChangeType changeType;

  @override
  final UserReference modifier;

  final Reception reception;

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

  ReceptionChangelogEntry.fromJson(Map<String, dynamic> map)
      : modifier =
            UserReference.decode(map['modifier'] as Map<String, dynamic>),
        reception = Reception.decode(map['reception'] as Map<String, dynamic>),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'reception': reception.toJson()
      };
}

class OrganizationChangelogEntry implements ChangelogEntry {
  @override
  final DateTime timestamp;

  @override
  final ChangeType changeType;

  @override
  final UserReference modifier;

  final Organization organization;

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

  OrganizationChangelogEntry.fromJson(Map<String, dynamic> map)
      : modifier =
            UserReference.decode(map['modifier'] as Map<String, dynamic>),
        organization =
            Organization.decode(map['organization'] as Map<String, dynamic>),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'organization': organization.toJson()
      };
}

class UserChangelogEntry implements ChangelogEntry {
  @override
  final DateTime timestamp;

  @override
  final ChangeType changeType;

  @override
  final UserReference modifier;

  final User user;

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

  UserChangelogEntry.fromJson(Map<String, dynamic> map)
      : modifier =
            UserReference.decode(map['modifier'] as Map<String, dynamic>),
        user = User.decode(map['user'] as Map<String, dynamic>),
        changeType = changeTypeFromString(map['change']),
        timestamp = util.unixTimestampToDateTime(map['timestamp']);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'change': changeTypeToString(changeType),
        'timestamp': util.dateTimeToUnixTimestamp(timestamp),
        'modifier': modifier.toJson(),
        'user': user.toJson()
      };
}

/// Different object types available for storage.
///
/// Matches model classes that needs persistent storage.
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
const Map<ObjectType, String> _objectTypeToString = const <ObjectType, String>{
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
const Map<String, ObjectType> _objectTypeFromString =
    const <String, ObjectType>{
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

/// Convert an [ObjectType] to a [String]. Suitable for serialization.
String objectTypeToString(ObjectType ct) => _objectTypeToString.containsKey(ct)
    ? _objectTypeToString[ct]
    : throw new ArgumentError('Unknown ObjectType $ct');

/// Convert a [String] to an [ObjectType]. Suitable for deserialization.
ObjectType objectTypeFromString(String str) =>
    _objectTypeFromString.containsKey(str)
        ? _objectTypeFromString[str]
        : throw new ArgumentError('Unknown ObjectType $str');

enum ChangeType { add, delete, modify }

String changeTypeToString(ChangeType ct) => _changeTypeToString.containsKey(ct)
    ? _changeTypeToString[ct]
    : throw new ArgumentError('Unknown ChangeType $ct');

ChangeType changeTypeFromString(String str) =>
    _changeTypeFromString.containsKey(str)
        ? _changeTypeFromString[str]
        : throw new ArgumentError('Unknown ChangeType $str');

const Map<ChangeType, String> _changeTypeToString = const <ChangeType, String>{
  ChangeType.add: 'A',
  ChangeType.modify: 'M',
  ChangeType.delete: 'D'
};

const Map<String, ChangeType> _changeTypeFromString =
    const <String, ChangeType>{
  'A': ChangeType.add,
  'M': ChangeType.modify,
  'D': ChangeType.delete
};

abstract class ObjectChange {
  ChangeType get changeType;
  ObjectType get objectType;

  static ObjectChange decode(Map<String, dynamic> map) {
    final ObjectType objectType = objectTypeFromString(map[key.type]);

    switch (objectType) {
      case ObjectType.calendar:
        return CalendarChange.decode(map);
      case ObjectType.contact:
        return new ContactChange(
            changeTypeFromString(map[key.change]), map[key.cid]);
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

  Map<String, dynamic> toJson();
}

/// Class representing a historic change, by a [User].
class Commit {
  DateTime changedAt;
  String authorIdentity;
  String commitHash;
  int uid = User.noId;
  List<ObjectChange> changes = <ObjectChange>[];

  /// Default constructor.
  Commit();

  /// Deserializing constructor.
  Commit.fromJson(Map<String, dynamic> map)
      : changes = new List<ObjectChange>.from(
            (map[key.changes] as Iterable<Map<String, dynamic>>)
                .map(ObjectChange.decode)),
        authorIdentity = map[key.identity],
        changedAt = util.unixTimestampToDateTime(map[key.updatedAt]),
        commitHash = map[key.commitHash],
        uid = map[key.uid];

  /// Decoding factory.
  @deprecated
  static Commit decode(Map<String, dynamic> map) => new Commit.fromJson(map);

  /// Returns a map representation of the object.
  ///
  /// Suitable for serialization.
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.identity: authorIdentity,
        key.updatedAt: util.dateTimeToUnixTimestamp(changedAt),
        key.commitHash: commitHash,
        key.uid: uid,
        key.changes: new List<Map<String, dynamic>>.from(
            changes.map((ObjectChange c) => c.toJson()))
      };
}

class IvrChange implements ObjectChange {
  @override
  final ChangeType changeType;
  @override
  final ObjectType objectType = ObjectType.ivrMenu;
  final String menuName;

  IvrChange(this.changeType, this.menuName);

  IvrChange.fromJson(Map<String, dynamic> map)
      : changeType = changeTypeFromString(map[key.change]),
        menuName = map[key.name];

  static IvrChange decode(Map<String, dynamic> map) =>
      new IvrChange(changeTypeFromString(map[key.change]), map[key.name]);

  /// Returns a map representation of the object.
  ///
  /// Suitable for serialization.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.name: menuName
      };
}

class ReceptionDialplanChange implements ObjectChange {
  @override
  final ChangeType changeType;
  @override
  final ObjectType objectType = ObjectType.dialplan;
  final String extension;

  ReceptionDialplanChange(this.changeType, this.extension);

  ReceptionDialplanChange.fromJson(Map<String, dynamic> map)
      : changeType = changeTypeFromString(map[key.change]),
        extension = map[key.name];

  static ReceptionDialplanChange decode(Map<String, dynamic> map) =>
      new ReceptionDialplanChange(
          changeTypeFromString(map[key.change]), map[key.name]);

  /// Returns a map representation of the object.
  ///
  /// Suitable for serialization.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.name: extension
      };
}

class MessageChange implements ObjectChange {
  @override
  final ChangeType changeType;

  @override
  final ObjectType objectType = ObjectType.message;
  final int mid;

  MessageChange(this.changeType, this.mid);

  MessageChange.fromJson(Map<String, dynamic> map)
      : changeType = changeTypeFromString(map[key.change]),
        mid = map[key.mid];

  static MessageChange decode(Map<String, dynamic> map) =>
      new MessageChange.fromJson(map);

  /// Returns a map representation of the object.
  ///
  /// Suitable for serialization.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.mid: mid
      };
}

class OrganizationChange implements ObjectChange {
  @override
  final ChangeType changeType;
  @override
  final ObjectType objectType = ObjectType.organization;
  final int oid;

  OrganizationChange(this.changeType, this.oid);

  OrganizationChange.fromJson(Map<String, dynamic> map)
      : changeType = changeTypeFromString(map[key.change]),
        oid = map[key.mid];

  static OrganizationChange decode(Map<String, dynamic> map) =>
      new OrganizationChange.fromJson(map);

  /// Returns a map representation of the object.
  ///
  /// Suitable for serialization.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.mid: oid
      };
}

class ReceptionChange implements ObjectChange {
  @override
  final ChangeType changeType;
  @override
  final ObjectType objectType = ObjectType.reception;
  final int rid;

  ReceptionChange(this.changeType, this.rid);

  ReceptionChange.fromJson(Map<String, dynamic> map)
      : changeType = changeTypeFromString(map[key.change]),
        rid = map[key.mid];

  static ReceptionChange decode(Map<String, dynamic> map) =>
      new ReceptionChange.fromJson(map);

  /// Returns a map representation of the object.
  ///
  /// Suitable for serialization.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.mid: rid
      };
}
