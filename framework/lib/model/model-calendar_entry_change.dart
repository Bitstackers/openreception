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
  DateTime changedAt;
  int userId;
  String author;
  String parentRef;

  /**
   * Default constructor.
   */
  CalendarEntryChange();

  /**
   * Deserializing constructor.
   */
  CalendarEntryChange.fromMap(Map map)
      : userId = map[Key.userId],
        changedAt = Util.unixTimestampToDateTime(map[Key.updatedAt]),
        parentRef = map[Key.parentRef];

  /**
   * Decoding factory.
   */
  static CalendarEntryChange decode(Map map) =>
      new CalendarEntryChange.fromMap(map);

  /**
   * Returns a map representation of the object.
   * Suitable for serialization.
   */
  Map toJson() => {
        Key.userId: userId,
        Key.updatedAt: Util.dateTimeToUnixTimestamp(changedAt),
        Key.parentRef: parentRef
      };
}
