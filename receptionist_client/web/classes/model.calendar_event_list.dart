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
 * A list of [CalendarEvent] objects.
 */
class CalendarEventList extends IterableBase<CalendarEvent>{
  List<CalendarEvent> _list = new List<CalendarEvent>();

  Iterator<CalendarEvent> get iterator => _list.iterator;

  /**
   * [CalendarEventList] constructor.
   */
  CalendarEventList();

  /**
   * [CalendarEventList] constructor. Builds a list of [CalendarEvent] objects
   * from the contents of json[key].
   */
  factory CalendarEventList.fromJson(Map json, String key) {
    CalendarEventList calendarEventList = new CalendarEventList();

    if (json.containsKey(key) && json[key] is List) {
      log.debug('model.CalendarEventList.fromJson key: ${key} list: ${json[key]}');
      calendarEventList = new CalendarEventList._fromList(json[key]);
    } else {
      log.critical('model.CalendarEventList.fromJson bad data key: ${key} map: ${json}');
    }

    return calendarEventList;
  }

  /**
   * [CalendarEventList] internal constructor.
   */
  CalendarEventList._fromList(List<Map> list) {
    list.forEach((item) => _list.add(new CalendarEvent.fromJson(item)));
    _list.sort();
  }
}
