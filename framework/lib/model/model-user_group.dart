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
class UserGroup {
  int    id;
  String name;

  /**
   *
   */
  UserGroup.empty();

  /**
   *
   * FIXME: Turn value into a Map once the auth server is using the framework
   *   models.
   */
  UserGroup.fromMap(var value) {
    if (value is String) {
      name = value;
    }
    else {
      id   = value['id'];
      name = value['name'];

    }

  }

  static UserGroup decode (var map) => new UserGroup.fromMap(map);

  /**
   *
   */
  Map toJson() {
    Map data = {
      'id': id,
      'name': name
    };

    return data;
  }

  /**
   *
   */
  @override
  operator == (UserGroup other) =>
     this.id == other.id && this.name == other.name;

  /**
   *
   */
  @override
  int get hashCode => name.hashCode;
}

int compareUserGroup (UserGroup g1, UserGroup g2) => g1.name.compareTo(g2.name);