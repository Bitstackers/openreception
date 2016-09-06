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

abstract class UserGroups {
  static const String receptionist = 'Receptionist';
  static const String administrator = 'Administrator';
  static const String serviceAgent = 'Service agent';

  static const Iterable<String> validGroups = const <String>[
    receptionist,
    administrator,
    serviceAgent
  ];

  static bool isValid(String group) => validGroups.toSet().contains(group);
}

class UserChange implements ObjectChange {
  @override
  final ChangeType changeType;

  @override
  final ObjectType objectType = ObjectType.user;
  final int uid;

  UserChange(this.changeType, this.uid);

  UserChange.fromJson(Map<String, dynamic> map)
      : changeType = changeTypeFromString(map[key.change]),
        uid = map[key.uid];

  static UserChange decode(Map<String, dynamic> map) =>
      new UserChange(changeTypeFromString(map[key.change]), map[key.uid]);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.uid: uid
      };
}

class UserReference implements ObjectReference {
  @override
  final int id;
  @override
  final String name;

  const UserReference(this.id, this.name);

  static UserReference decode(Map<String, dynamic> map) =>
      new UserReference(map[key.id], map[key.name]);

  /// Serialization function.
  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{key.id: id, key.name: name};

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is UserReference && other.id == id;
}

class User {
  static const int noId = 0;

  String address;
  int id = noId;
  String name = '';
  String extension = '';
  String portrait = '';
  Set<String> groups = new Set<String>();
  Set<String> identities = new Set<String>();

  /// Constructor for creating an empty object.
  User.empty();

  /// Deserializing constructor.
  User.fromMap(Map<String, dynamic> map)
      : id = map[key.id],
        address = map[key.address],
        name = map[key.name],
        extension = map[key.extension],
        groups = new Set<String>.from(map[key.groups]),
        identities = new Set<String>.from(map[key.identites]),
        portrait = map.containsKey('remote_attributes') &&
                (map['remote_attributes'] as Map<String, dynamic>)
                    .containsKey('picture')
            ? (map['remote_attributes'] as Map<String, dynamic>)['picture']
            : '';

  /// Deserializing factory
  static User decode(Map<String, dynamic> map) => new User.fromMap(map);

  /// Serialization function.
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.id: id,
        key.name: name,
        key.identites: identities.toList(growable: false),
        key.address: address,
        key.extension: extension,
        key.groups: groups.toList(growable: false)
      };

  UserReference get reference => new UserReference(id, name);
}
