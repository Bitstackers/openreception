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
 * JSON serialization keys.
 */
abstract class CalendarEntryChangeKey {
  static const String userID = 'uid';
  static const String updatedAt = 'updated';
  static const String username = 'username';
}

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
    this.userID = map[CalendarEntryChangeKey.userID];
    this.changedAt = Util.unixTimestampToDateTime(map[CalendarEntryChangeKey.updatedAt]);
    this.username = map[CalendarEntryChangeKey.username];
  }

  /**
   * Returns a map representation of the object.
   * Suitable for serialization.
   */
  Map get asMap => {
    CalendarEntryChangeKey.userID : this.userID,
    CalendarEntryChangeKey.updatedAt : Util.dateTimeToUnixTimestamp(changedAt),
    CalendarEntryChangeKey.username : this.username
  };

  /**
   * Serialization function.
   */
  Map toJson() => this.asMap;
}