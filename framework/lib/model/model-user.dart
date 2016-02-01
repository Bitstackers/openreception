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
class User {
  static const int noID = 0;

  String address;

  @deprecated
  int get ID => id;
  @deprecated
  void set ID(int newId) {
    id = newId;
  }

  int id;
  bool enabled = true;

  String name;
  String peer;
  String portrait = '';

  /// Google gmail sending credentials.
  String googleUsername = '';
  String googleAppcode = '';

  /**
   * Constructor for creating an empty object.
   */
  User.empty();

  /**
   * Constructor.
   */
  User.fromMap(Map map)
      : address = map[Key.address],
        id = map[Key.id],
        name = map[Key.name],
        peer = map[Key.extension],
        googleUsername =
            map.containsKey(Key.googleUsername) ? map[Key.googleUsername] : '',
        googleAppcode =
            map.containsKey(Key.googleAppcode) ? map[Key.googleAppcode] : '' {
    portrait = map.containsKey('remote_attributes') &&
            (map['remote_attributes'] as Map).containsKey('picture')
        ? portrait = (map['remote_attributes'] as Map)['picture']
        : '';
  }

  /**
   *
   */
  @deprecated
  Map get asSender => {'name': name, 'id': id, 'address': address};

  /**
   *
   */
  @deprecated
  Map get asMap => toJson();

  /**
   *
   */
  Map toJson() => {
        Key.id: id,
        Key.name: name,
        Key.address: address,
        Key.extension: peer,
        Key.googleUsername: googleUsername,
        Key.googleAppcode: googleAppcode
      };
}
