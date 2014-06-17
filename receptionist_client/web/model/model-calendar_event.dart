/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * A calendar event.
 */
class CalendarEvent implements Comparable{
  bool      active = false;
  String   _content;
  DateTime _start;
  DateTime _stop;
  
  int      _contactID   = nullContact.id;
  int      _receptionID = nullReception.ID;

  String get start       => _formatTimestamp(_start);
  String get stop        => _formatTimestamp(_stop);
  String get content     => this._content;
  int    get contactID   => this._contactID;
  int    get receptionID => this._receptionID;

  void set beginsAt (DateTime start) {
    this._start = start;
  }

  void set until (DateTime stop) {
    this._stop = stop;
  }
  
  void set content (String eventBody) {
    this._content = eventBody;
  }
  
  CalendarEvent.forContact (this._contactID, this._receptionID);

  CalendarEvent.forReception (this._receptionID);
  
  Future save () {
    /// Dispatch to the correct service.
    if (this._contactID != nullContact.id) {
      return Service.Contact.calendarEventCreate (this);
    } else if (this._receptionID != nullReception.ID) {
      return Service.Reception.calendarEventCreate (this);
    } else {
      return new Future(() { throw new StateError("Trying to update an event object without an owner!");});
    }
  }
  
  Map toJson () => {'start'  : _timeToEpoch(this._start),
                    'stop'   : _timeToEpoch(this._stop),
                    'content': this._content};

  static int _timeToEpoch(DateTime time) => time.millisecondsSinceEpoch~/1000;
  
  /**
   * [CalendarEvent] constructor. Expects a map in the following format:
   *
   *  {
   *    'start'   : DateTime String,
   *    'stop'    : DateTime String,
   *    'content' : String
   *  }
   *
   *  'start' and 'stop' MUST be in a format that can be parsed by the
   *  [DateTime.parse] method. 'content' is the actual event description.
   *
   * TODO Obviously the above map format should be in the docs/wiki, as it is
   * also highly relevant to Alice.
   */
  CalendarEvent.fromJson(Map json) {
    final DateTime now = new DateTime.now();
    
    _start = DateTime.parse(json['start']);
    _stop = DateTime.parse(json['stop']);
    _content = json['content'];

    active = _start.millisecondsSinceEpoch <= now.millisecondsSinceEpoch && now.millisecondsSinceEpoch <= _stop.millisecondsSinceEpoch;
  }

  /**
   * Format the [DateTime] [stamp] timestamp into a string. If [stamp] is today
   * then return hour:minute, else return day/month hour:minute. Append year if
   * [stamp] is in another year than now.
   */
  String _formatTimestamp(DateTime stamp) {
    final String       day        = new DateFormat.d().format(stamp);
    final String       hourMinute = new DateFormat.Hm().format(stamp);
    final String       month      = new DateFormat.M().format(stamp);
    final DateTime     now        = new DateTime.now();
    final StringBuffer output     = new StringBuffer();
    final String       year       = new DateFormat.y().format(stamp);

    if (new DateFormat.yMd().format(stamp) != new DateFormat.yMd().format(now)) {
      output.write('${day}/${month}');
    }

    if (new DateFormat.y().format(stamp) != new DateFormat.y().format(now)) {
      output.write('/${year.substring(2)}');
    }

    output.write(' ${hourMinute}');

    return output.toString();
  }

  /**
   * Enables a [CalendarEvent] to sort itself compared to other calendar events.
   */
  int compareTo(CalendarEvent other) {
    if(_start.isAtSameMomentAs(other._start)) {
      return 0;
    }

    return _start.isBefore(other._start) ? -1 : 1;
  }

  /**
   * [CalendarEvent] as String, for debug/log purposes.
   */
  String toString() => _content;
}
