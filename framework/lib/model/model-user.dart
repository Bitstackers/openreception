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

abstract class UserGroups {
  static const String receptionist = 'Receptionist';
  static const String administrator = 'Administrator';
  static const String serviceAgent = 'Service agent';
}

/**
 *
 */
class User {
  static const int noId = 0;

  String address;

  bool enabled = true;

  int id = noId;
  String name = '';
  String peer = '';
  String portrait = '';
  List<String> groups = [];

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
        peer = map[Key.extension],
        groups = map[Key.groups],
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
        Key.address: address,
        Key.extension: peer,
        Key.groups: groups
      };
}
