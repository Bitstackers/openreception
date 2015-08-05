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

abstract class UserKey {
  static const String address = 'address';
  static const String groups = 'groups';
  static const String id = 'id';
  static const String identites = 'identites';
  static const String name = 'name';
  static const String extension = 'extension';
  static const String googleUsername = 'google_username';
  static const String googleAppcode ='google_appcode';
}

/**
 *
 */
class User {
  String             address;
  List<UserGroup>    groups = [];
  int                ID;
  List<UserIdentity> identities = [];
  String             name;
  static const int   noID      = 0;
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
        userMap.containsKey(UserKey.groups)
        ? userMap[UserKey.groups]
        : [];

    Iterable<Map> identityMaps =
        userMap.containsKey(UserKey.identites)
        ? userMap[UserKey.identites]
        : [];

    groups.addAll(groupMaps.map(UserGroup.decode));
    identities.addAll(identityMaps.map(UserIdentity.decode));

    address    = userMap[UserKey.address];
    ID         = userMap[UserKey.id];
    name       = userMap[UserKey.name];
    peer       = userMap[UserKey.extension];

    /// Google gmail sending credentials.
    if (userMap.containsKey(UserKey.googleUsername)) {
      googleUsername = userMap[UserKey.googleUsername];
    }
    if (userMap.containsKey(UserKey.googleAppcode)) {
      googleAppcode  = userMap[UserKey.googleAppcode];
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
    UserKey.id             : ID,
    UserKey.name           : name,
    UserKey.address        : address,
    UserKey.groups         : groups,
    UserKey.identites      : identities,
    UserKey.extension      : peer,
    UserKey.googleUsername : googleUsername,
    UserKey.googleAppcode  : googleAppcode
  };

  Map toJson() => this.asMap;

  /**
   *
   */
  bool inAnyGroups(List<String> groupNames) => groupNames.any(groups.contains);
}
