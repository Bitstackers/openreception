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
abstract class UserGroups {
  static const String receptionist = 'Receptionist';
  static const String administrator = 'Administrator';
  static const String serviceAgent = 'Service agent';

  static const Iterable<String> validGroups = const [
    receptionist,
    administrator,
    serviceAgent
  ];
}

/**
 *
 */
class UserChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.user;
  final int uid;

  /**
   *
   */
  UserChange(this.changeType, this.uid);

  /**
   *
   */
  static UserChange decode(Map map) =>
      new UserChange(changeTypeFromString(map[Key.change]), map[Key.uid]);

  /**
   *
   */
  UserChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[Key.change]),
        uid = map[Key.uid];

  /**
   *
   */
  Map toJson() => {
        Key.change: changeTypeToString(changeType),
        Key.type: objectTypeToString(objectType),
        Key.uid: uid
      };
}

/**
 *
 */
class UserReference implements ObjectReference {
  final int id;
  final String name;

  const UserReference(this.id, this.name);

  static UserReference decode(Map map) =>
      new UserReference(map[Key.id], map[Key.name]);

  Map toJson() => {Key.id: id, Key.name: name};

  int get hashCode => id.hashCode;
}

/**
 *
 */
class User {
  static const int noId = 0;

  String address;
  int id = noId;
  String name = '';
  String extension = '';
  String portrait = '';
  Set<String> groups = new Set<String>();
  Set<String> identities = new Set<String>();

  /**
   * Constructor for creating an empty object.
   */
  User.empty();

  /**
   * Deserializing factory
   */
  static User decode(Map map) => new User.fromMap(map);

  /**
   * Constructor.
   */
  User.fromMap(Map map)
      : id = map[Key.id],
        address = map[Key.address],
        name = map[Key.name],
        extension = map[Key.extension],
        groups = new Set<String>.from(map[Key.groups]),
        identities = new Set<String>.from(map[Key.identites]),
        portrait = map.containsKey('remote_attributes') &&
                (map['remote_attributes'] as Map).containsKey('picture')
            ? (map['remote_attributes'] as Map)['picture']
            : '';

  /**
   *
   */
  Map toJson() => {
        Key.id: id,
        Key.name: name,
        Key.identites: identities.toList(growable: false),
        Key.address: address,
        Key.extension: extension,
        Key.groups: groups.toList(growable: false)
      };

  /**
   *
   */
  UserReference get reference => new UserReference(id, name);
}
