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

  String content;
  DateTime start;
  DateTime stop;

  Owner owner = Owner.none;

  bool get isOwnedByContact => owner is OwningContact;

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
      : id = map[Key.id],
        owner = new Owner.parse(map[Key.owner]),
        start = Util.unixTimestampToDateTime(map[Key.start]),
        stop = Util.unixTimestampToDateTime(map[Key.stop]),
        content = map[Key.body];

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
   * Return the contact id for this calendar entry. MAY be [ReceptionAttributes.noID] if
   * this is a reception only entry.
   */
  int get contactId =>
      owner is OwningContact ? owner.id : ReceptionAttributes.noId;

  /**
   * ID of owning reception.
   */
  int get receptionId => owner is OwningReception ? owner.id : Reception.noId;

  /**
   * Serialization function.
   */
  Map toJson() => {
        Key.id: id,
        Key.owner: owner.toJson(),
        Key.body: content,
        Key.start: Util.dateTimeToUnixTimestamp(start),
        Key.stop: Util.dateTimeToUnixTimestamp(stop)
      };

  /**
   * [CalendarEntry] as String, for debug/log purposes.
   */
  String toString() => toJson().toString();
}
