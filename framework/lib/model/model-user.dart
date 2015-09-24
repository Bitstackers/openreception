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

  static const int   noID      = 0;

  String             address;
  List<UserGroup>    groups = [];
  int                ID;
  bool               enabled = true;
  List<UserIdentity> identities = [];
  String             name;
  String             peer;
  String             portrait = '';
  String             googleUsername = '';
  String             googleAppcode = '';

  /**
   * Constructor for creating an empty object.
   */
  User.empty();

  /**
   * Constructor.
   */
  User.fromMap(Map userMap) {
    Iterable<Map> groupMaps =
        userMap.containsKey(Key.groups)
        ? userMap[Key.groups]
        : [];

    Iterable<Map> identityMaps =
        userMap.containsKey(Key.identites)
        ? userMap[Key.identites]
        : [];

    groups.addAll(groupMaps.map(UserGroup.decode));
    identities.addAll(identityMaps.map(UserIdentity.decode));

    address    = userMap[Key.address];
    ID         = userMap[Key.id];
    name       = userMap[Key.name];
    peer       = userMap[Key.extension];

    /// Google gmail sending credentials.
    if (userMap.containsKey(Key.googleUsername)) {
      googleUsername = userMap[Key.googleUsername];
    }
    if (userMap.containsKey(Key.googleAppcode)) {
      googleAppcode  = userMap[Key.googleAppcode];
    }

    /// Remote attributes from Google account.
    if(userMap.containsKey('remote_attributes')) {
      if((userMap['remote_attributes'] as Map).containsKey('picture')) {
        portrait = userMap['remote_attributes']['picture'];
      }
    }
  }

  /**
   *
   */
  Map get asSender => {'name'   : name,
                       'id'     : ID,
                       'address': address};

  /**
   *
   */
  Map get asMap => {
    Key.id             : ID,
    Key.name           : name,
    Key.address        : address,
    Key.groups         : groups,
    Key.identites      : identities,
    Key.extension      : peer,
    Key.googleUsername : googleUsername,
    Key.googleAppcode  : googleAppcode
  };

  Map toJson() => this.asMap;

  /**
   *
   */
  bool inAnyGroups(List<String> groupNames) =>
    groupNames.any(groups.map((UserGroup group) => group.name).contains);
}
