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
 * CalendarEntry class representing a single entry in a calendar. Can be owned
 * by either a contact or a reception.
 *
 * TODO: Move keys to keys package.
 */
class CalendarEntry {
  static final String className = '${libraryName}.CalendarEntry';
  static final Logger log = new Logger(className);
  int ID = CalendarEntry.noID;

  String _content;
  static const int noID = 0;
  DateTime _start;
  DateTime _stop;

  Owner owner = Owner.none;

  bool get isOwnedByContact => owner is OwningContact;

  /**
   * Constructor.
   */
  CalendarEntry.empty();

  /**
   * Constructor for [Contact] calendar entries.
   */
  @deprecated
  CalendarEntry.contact(int contactId, int receptionId) {
    owner = new OwningContact(contactId);
  }

  /**
   * Constructor for [Reception] calendar entries.
   */
  @deprecated
  CalendarEntry.reception(int receptionId) {
    owner = new OwningReception(receptionId);
  }

  /**
   * [CalendarEntry] deserializing constructor.
   * 'start' and 'stop' MUST be in a format that can be parsed by the
   * [DateTime.parse] method. Please use the methods in the [Util] library to
   * help getting the right format. 'content' is the actual entry body.
   */
  CalendarEntry.fromMap(Map json) {
    ID = json['id'];
    owner = new Owner.parse(json['owner']);
    _start = Util.unixTimestampToDateTime(json['start']);
    _stop = Util.unixTimestampToDateTime(json['stop']);
    _content = json['content'];
  }

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
    return (now.isAfter(_start) && now.isBefore(_stop));
  }

  /**
   * Returns a map representation of the calendar entry.
   * Suitable for serialization.
   */
  Map get asMap => {
        'id': ID,
        'owner': owner.toJson(),
        'start': Util.dateTimeToUnixTimestamp(start),
        'stop': Util.dateTimeToUnixTimestamp(stop),
        'content': content
      };

  /**
   * The calendar entry starts at [start].
   */
  void set beginsAt(DateTime start) {
    _start = start;
  }

  /**
   * Return the contact id for this calendar entry. MAY be [Contact.noID] if
   * this is a reception only entry.
   */
  int get contactID => owner is OwningContact
      ? (owner as OwningContact).contactId
      : Contact.noID;

  /**
   * Get the actual calendar entry text content.
   */
  String get content => _content;

  /**
   * Set the calendar entry text content.
   */
  void set content(String entryBody) {
    _content = entryBody;
  }

  /**
   * ID of owning reception.
   */
  int get receptionID => owner is OwningReception
      ? (owner as OwningReception).receptionId
      : Reception.noID;

  /**
   * When this calendar entry begins.
   */
  DateTime get start => _start;

  /**
   * When this calendar entry ends.
   */
  DateTime get stop => _stop;

  /**
   * Serialization function.
   */
  Map toJson() => asMap;

  /**
   * [CalendarEntry] as String, for debug/log purposes.
   */
  String toString() => 'start: ${start.toIso8601String()}, '
      'stop: ${stop.toIso8601String()}, '
      'rid: ${receptionID}, '
      'cid: ${contactID}, '
      'content: ${content}';

  /**
   * The calendar entry ends at [stop].
   */
  void set until(DateTime stop) {
    _stop = stop;
  }
}
