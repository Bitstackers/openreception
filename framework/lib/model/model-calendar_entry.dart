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
 */
class CalendarEntry {
  static final String className = '${libraryName}.CalendarEntry';
  static final Logger log       = new Logger(className);

  int              _contactID   = Contact.noID;
  String           _content;
  int              _ID          = CalendarEntry.noID;
  static const int noID         = 0;
  int              _receptionID = Reception.noID;
  DateTime         _start;
  DateTime         _stop;

  bool get isOwnedByContact => _contactID != Contact.noID;

  /**
   * Constructor.
   */
  CalendarEntry.empty();

  /**
   * Constructor for [Contact] calendar entries.
   */
  CalendarEntry.contact(this._contactID, this._receptionID);

  /**
   * Constructor for [Reception] calendar entries.
   */
  CalendarEntry.reception(this._receptionID);

  /**
   * [CalendarEntry] constructor. Expects a map in the following format:
   *
   *  {
   *    'id'               : int entry id,
   *    'reception_id'     : int reception id,
   *    'contact_id'       : int contact id (optional),
   *    'start'            : DateTime String,
   *    'stop'             : DateTime String,
   *    'content'          : String,
   *    'last_modified'    : DateTime String,
   *    'last_modified_by' : int user id
   *  }
   *
   * 'start' and 'stop' MUST be in a format that can be parsed by the
   * [DateTime.parse] method. Please use the methods in the [Util] library to
   * help getting the right format. 'content' is the actual entry body.
   */
  CalendarEntry.fromMap(Map json) {
    _ID              = json['id'];
    _receptionID     = json['reception_id'];
    _contactID       = json['contact_id'] != null ? json['contact_id'] : Contact.noID;
    _start           = Util.unixTimestampToDateTime(json['start']);
    _stop            = Util.unixTimestampToDateTime(json['stop']);
    _content         = json['content'];
  }

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
  Map get asMap =>
      {'id'               : ID,
       'contact_id'       : contactID != Contact.noID ? contactID : null,
       'reception_id'     : receptionID,
       'start'            : Util.dateTimeToUnixTimestamp(start),
       'stop'             : Util.dateTimeToUnixTimestamp(stop),
       'content'          : content
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
  int get contactID => _contactID;

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
   * The current id of the entry. Note that entries with [noID] will be created
   * in the store and given an id upon return.
   */
  int get ID => _ID;

  /**
   * Update the entry id.
   */
  void set ID(int newID) {
    if (_ID != noID) {
      throw new ArgumentError.value(newID, 'newID',
          'Cannot set ID of a ''CalendarEntry that already has an ID');
    }

    _ID = newID;
  }

  /**
   * ID of owning reception.
   */
  int get receptionID => _receptionID;

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
