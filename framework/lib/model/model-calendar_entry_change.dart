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
 * Class representing a historic change, by a [User] in a [CalendarEntry].
 */
class CalendarEntryChange {

  int userID = User.noID;
  DateTime changedAt;
  String username;

  /**
   * Default constructor.
   */
  CalendarEntryChange();

  /**
   * Deserializing constructor.
   */
  CalendarEntryChange.fromMap(Map map) {
    this.userID = map[Key.userID];
    this.changedAt = Util.unixTimestampToDateTime(map[Key.updatedAt]);
    this.username = map[Key.username];
  }

  /**
   * Returns a map representation of the object.
   * Suitable for serialization.
   */
  Map get asMap => {
    Key.userID : this.userID,
    Key.updatedAt : Util.dateTimeToUnixTimestamp(changedAt),
    Key.username : this.username
  };

  /**
   * Serialization function.
   */
  Map toJson() => this.asMap;
}