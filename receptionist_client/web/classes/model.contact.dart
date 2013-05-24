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

final Contact nullContact = new Contact._null();

/**
 * TODO comment
 */
class Contact implements Comparable{
  CalendarEventList _calendarEventList = nullCalendarEventList;
  CalendarEventList get calendarEventList => _calendarEventList;

  int id;
  bool isHuman;
  String name;

  Contact(Map json) {
    id = json['contact_id'];
    isHuman = json['is_human'];
    name = json['full_name'];

    // Add some dummy calendar events
    List tempEvents = new List();
    tempEvents.add({'start':'2013-12-20 10:00:00', 'stop':'2014-01-05 12:00:00', 'content':'${id} Kursus I Shanghai. Tjekker sin email.'});
    tempEvents.add({'start':'2013-05-01 08:00:00', 'stop':'2014-02-07 17:00:00', 'content':'${id} Jordomrejse'});
    _calendarEventList = new CalendarEventList(tempEvents);
  }

  Contact._null();

  int compareTo(Contact other) => name.compareTo(other.name);

  String toString() => '${name}-${id}-${isHuman}';
}
