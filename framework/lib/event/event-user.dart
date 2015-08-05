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

part of openreception.event;

/**
 * 'Enum' representing different outcomes of a [User] change.
 */
abstract class UserObjectState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class UserChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.userChange;

  final int userID;
  final String state;

  UserChange._internal (this.userID, this.state) :
    timestamp = new DateTime.now();

  factory UserChange.created (int userID) =>
    new UserChange._internal(userID, UserObjectState.CREATED);

  factory UserChange.updated (int userID) =>
    new UserChange._internal(userID, UserObjectState.UPDATED);

  factory UserChange.deleted (int userID) =>
    new UserChange._internal(userID, UserObjectState.DELETED);

  Map toJson() => this.asMap;

  @override
  String toString() => 'UserChange, uid:$userID, state:$state';

  Map get asMap {
    final Map template = EventTemplate._rootElement(this);

    final Map body = {Key.userID : userID,
                Key.state  : state};

    template[this.eventName] = body;

    return template;
  }

  UserChange.fromMap (Map map) :
    userID = map[Key.userChange][Key.userID],
    state = map[Key.userChange][Key.state],
    timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}