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

part of openreception.framework.model;

/**
 * CalendarEntry class representing a single entry in a calendar. Can be owned
 * by either a contact or a reception.
 */
class CalendarEntry {
  static const int noId = 0;

  int id = noId;
  int lastAuthorId = User.noId;

  String content = '';
  DateTime start = util.never;
  DateTime stop = util.never;

  /**
   * Constructor.
   */
  CalendarEntry.empty();

  /**
   * [CalendarEntry] deserializing constructor.
   * 'start' and 'stop' MUST be in a format that can be parsed by the
   * [DateTime.parse] method. Please use the methods in the [Util] library to
   * help getting the right format. 'content' is the actual entry body.
   */
  CalendarEntry.fromMap(Map map)
      : id = map[key.id],
        lastAuthorId = map[key.uid],
        start = util.unixTimestampToDateTime(map[key.start]),
        stop = util.unixTimestampToDateTime(map[key.stop]),
        content = map[key.body];

  /**
   * Decoding factory.
   */
  static CalendarEntry decode(Map map) => map.isNotEmpty
      ? new CalendarEntry.fromMap(map)
      : new CalendarEntry.empty();

  /**
   * Return true if now is between after [start] and before [stop].
   */
  bool get active {
    DateTime now = new DateTime.now();
    return (now.isAfter(start) && now.isBefore(stop));
  }

  /**
   * Serialization function.
   */
  Map toJson() => {
        key.id: id,
        key.uid: lastAuthorId,
        key.body: content,
        key.start: util.dateTimeToUnixTimestamp(start),
        key.stop: util.dateTimeToUnixTimestamp(stop)
      };

  /**
   * [CalendarEntry] as String, for debug/log purposes.
   */
  String toString() => toJson().toString();
}
