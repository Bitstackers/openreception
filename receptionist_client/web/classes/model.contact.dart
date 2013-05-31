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

final Contact nullContact = new Contact._null();

/**
 * A Contact
 */
class Contact implements Comparable{
  MiniboxList _backupList = nullMiniboxList;
  CalendarEventList _calendarEventList = nullCalendarEventList;
  MiniboxList _emailAddressList = nullMiniboxList;
  MiniboxList _handlingList = nullMiniboxList;
  MiniboxList _telephoneNumberList = nullMiniboxList;
  MiniboxList _workHoursList = nullMiniboxList;

  String department = '';
  int id;
  String info = '';
  bool isHuman;
  String name = '';
  String position = '';
  String relations = '';
  String responsibility = '';

  MiniboxList       get backupList => _backupList;
  CalendarEventList get calendarEventList => _calendarEventList;
  MiniboxList       get emailAddressList => _emailAddressList;
  MiniboxList       get handlingList => _handlingList;
  MiniboxList       get telephoneNumberList => _telephoneNumberList;
  MiniboxList       get workHoursList => _workHoursList;

  Contact(Map json) {
    id = json['contact_id'];
    isHuman = json['is_human'];
    name = json['full_name'];

    if(json.containsKey('attributes')) {
      Map attributes = json['attributes'][0];

      if(attributes.containsKey('backup')) {
        _backupList = new MiniboxList(attributes['backup']);
      } else {
        // Log bad json? Check schema somewhere else?
      }

      if(attributes.containsKey('emailaddresses')) {
        _emailAddressList = new MiniboxList(attributes['emailaddresses']);
      }

      if(attributes.containsKey('handling')) {
        _handlingList = new MiniboxList(attributes['handling']);
      }

      if(attributes.containsKey('telephonenumbers')) {
        _telephoneNumberList = new MiniboxList(attributes['telephonenumbers']);
      }

      if(attributes.containsKey('workhours')) {
        _workHoursList = new MiniboxList(attributes['workhours']);
      }

      department = attributes['department'];
      info = attributes['info'];
      position = attributes['position'];
      relations = attributes['relations'];
      responsibility = attributes['responsibility'];
    }

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
