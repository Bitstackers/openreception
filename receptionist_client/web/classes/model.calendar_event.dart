/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

part of model;

/**
 * TODO comment
 */
class CalendarEvent implements Comparable{
  String _content;
  DateTime _start;
  DateTime _stop;
  bool active =false;

  String get start => _formatTimestamp(_start);
  String get stop => _formatTimestamp(_stop);

  CalendarEvent(DateTime this._start, DateTime this._stop, String this._content);

  CalendarEvent.fromJson(Map json) {
    DateTime now = new DateTime.now();

    _start = DateTime.parse(json['start']);
    _stop = DateTime.parse(json['stop']);
    _content = json['content'];

    active = now == _start || now == _stop;

    if (!active && (now.isAfter(_start) && now.isBefore(_stop))) {
      active = true;
    }
  }

  /**
   * Format the [DateTime] [stamp] timestamp into a string. If [stamp] is today
   * then return hour:minute, else return day/month hour:minute. Append year if
   * [stamp] is in another year than now.
   */
  String _formatTimestamp(DateTime stamp) {
    StringBuffer output = new StringBuffer();
    DateTime now = new DateTime.now();

    String hourMinute = new DateFormat.Hm().format(stamp);
    String day = new DateFormat.d().format(stamp);
    String month = new DateFormat.M().format(stamp);
    String year = new DateFormat.y().format(stamp);

    if (new DateFormat.yMd().format(stamp) != new DateFormat.yMd().format(now)) {
      output.write('${day}/${month}');
    }

    if (new DateFormat.y().format(stamp) != new DateFormat.y().format(now)) {
      output.write('/${year.substring(2)}');
    }

    output.write(' ${hourMinute}');

    return output.toString();
  }

  int compareTo(CalendarEvent other) {
    if(_start.isAtSameMomentAs(other._start)) {
      return 0;
    }

    return _start.isBefore(other._start) ? -1 : 1;
  }

  String toString() => _content;
}
