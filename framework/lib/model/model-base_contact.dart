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
 * Available types for [BaseContact] objects.
 */
abstract class ContactType {
  static const String human = 'human';
  static const String function = 'function';
  static const String invisible = 'invisible';

  /// Iterable enumerating the different contact types.
  static const Iterable types = const [human, function, invisible];
}

abstract class ObjectReference {
  int get id;
  String get name;

  Map toJson();
}

class ContactReference implements ObjectReference {
  final int id;
  final String name;

  const ContactReference(this.id, this.name);

  static ContactReference decode(Map map) =>
      new ContactReference(map[Key.id], map[Key.name]);

  bool get isEmpty => id == BaseContact.noId;

  Map toJson() => {Key.id: id, Key.name: name};

  int get hashCode => id.hashCode;
}

/**
 *
 */
class ContactChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.contact;
  final int cid;

  /**
   *
   */
  ContactChange(this.changeType, this.cid);

  /**
   *
   */
  static ContactChange decode(Map map) =>
      new ContactChange(changeTypeFromString(map[Key.change]), map[Key.cid]);

  /**
   *
   */
  ContactChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[Key.change]),
        cid = map[Key.cid];

  /**
   *
   */
  Map toJson() => {
        Key.change: changeTypeToString(changeType),
        Key.type: objectTypeToString(objectType),
        Key.cid: cid
      };
}

class OrganizationReference implements ObjectReference {
  final int id;
  final String name;

  const OrganizationReference(this.id, this.name);

  static OrganizationReference decode(Map map) =>
      new OrganizationReference(map[Key.id], map[Key.name]);

  Map toJson() => {Key.id: id, Key.name: name};

  int get hashCode => id.hashCode;
}

class ReceptionContact {
  final BaseContact contact;
  final ReceptionAttributes attr;

  ReceptionContact.empty()
      : contact = new BaseContact.empty(),
        attr = new ReceptionAttributes.empty();

  ReceptionContact(this.contact, this.attr);

  static ReceptionContact decode(Map map) => new ReceptionContact(
      BaseContact.decode(map[Key.contact]),
      ReceptionAttributes.decode(map[Key.reception]));

  Map toJson() => {Key.contact: contact.toJson(), Key.reception: attr.toJson()};

  ContactReference get contactReference =>
      new ContactReference(contact.id, contact.name);
}

class ReceptionReference implements ObjectReference {
  final int id;
  final String name;

  const ReceptionReference(this.id, this.name);

  const ReceptionReference.none()
      : id = Reception.noId,
        name = '';

  bool get isEmpty => id == Reception.noId;
  bool get isNotEmpty => !isEmpty;

  static ReceptionReference decode(Map map) =>
      new ReceptionReference(map[Key.id], map[Key.name]);

  Map toJson() => {Key.id: id, Key.name: name};

  int get hashCode => id.hashCode;
}

/**
 * A base contact represents a contact outside the context of a reception.
 */
class BaseContact {
  static const int noId = 0;

  int id = noId;
  String name = '';

  ///TODO: Turn into enum.
  String type = '';
  bool enabled = true;

  /**
   * Default empty constructor.
   */
  BaseContact.empty();

  /**
   * Decoding factory.
   */
  static BaseContact decode(Map map) => new BaseContact.fromMap(map);

  /**
   * Deserializing constructor.
   */
  BaseContact.fromMap(Map map)
      : id = map[Key.id],
        name = map[Key.name],
        type = map[Key.contactType],
        enabled = map[Key.enabled];

  /**
   *
   */
  Map toJson() =>
      {Key.id: id, Key.name: name, Key.contactType: type, Key.enabled: enabled};

  /**
   *
   */
  ContactReference get reference => new ContactReference(id, name);

  /**
   *
   */
  bool get isEmpty => id == BaseContact.noId;

  bool get isNotEmpty => !isEmpty;
}
