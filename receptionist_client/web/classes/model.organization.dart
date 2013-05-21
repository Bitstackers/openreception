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

final Organization nullOrganization = new Organization._null();

/**
 * TODO comment
 */
class Organization{
  ContactList _contactlist = nullContactList;
  ContactList get contacts => _contactlist;

  CalendarEventList _calendarEventList = nullCalendarEventList;
  CalendarEventList get calendarEvents => _calendarEventList;

  String greeting = "";
  int id = -1;
  String name = "";

  Organization(Map json) {
    if(json.containsKey('contacts')) {
      _contactlist = new ContactList(json['contacts']);
      json.remove('contacts');
    }

    id = json['organization_id'];
    name = json['full_name'];
    greeting = json['greeting'];

    // Add some dummy calendar events
    List tempEvents = new List();
    tempEvents.add({'start':'2013-02-07 08:30:16', 'stop':'2014-02-07 14:45:00', 'content':'Ombygning af bygning der er alt for varm, og derfor ikke virker efter hensigten'});
    tempEvents.add({'start':'2013-05-17 07:37:16', 'stop':'2013-05-17 17:00:00', 'content':'Salgsmøde'});
    tempEvents.add({'start':'2013-12-20 10:00:00', 'stop':'2014-01-05 12:00:00', 'content':'Kursus'});
    _calendarEventList = new CalendarEventList(tempEvents);
  }

  Organization._null();

  String toString() => '${name}-${id}';
}
