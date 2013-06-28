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
 * A [Contact] object. Sorting contacts is done based on [name].
 */
class Contact implements Comparable{
  MiniboxList       _backupList          = nullMiniboxList;
  CalendarEventList _calendarEventList   = nullCalendarEventList;
  String            department           = '';
  MiniboxList       _emailAddressList    = nullMiniboxList;
  MiniboxList       _handlingList        = nullMiniboxList;
  int               id;
  String            info                 = '';
  bool              isHuman;
  String            name                 = '';
  String            position             = '';
  String            relations            = '';
  String            responsibility       = '';
  MiniboxList       _telephoneNumberList = nullMiniboxList;
  MiniboxList       _workHoursList       = nullMiniboxList;

  MiniboxList       get backupList => _backupList;
  CalendarEventList get calendarEventList => _calendarEventList;
  MiniboxList       get emailAddressList => _emailAddressList;
  MiniboxList       get handlingList => _handlingList;
  MiniboxList       get telephoneNumberList => _telephoneNumberList;
  MiniboxList       get workHoursList => _workHoursList;

  /**
   * [Contact] constructor. Expects a map in the following format:
   *
   * intString JSON object =
   *  {
   *    "priority": int,
   *    "value": String
   *  }
   *
   * Contact JSON object =
   *  {
   *    "full_name": String,
   *    "attributes": [
   *      {
   *        "relations": String,
   *        "workhours": [>= 0 intString objects],
   *        "department": String,
   *        "organization_id": int,
   *        "handling": [>= 0 intString objects],
   *        "telephonenumbers": [>= 0 intString objects],
   *        "responsibility": String,
   *        "emailaddresses": [>= 0 intString objects],
   *        "info": String,
   *        "position": String,
   *        "backup": [>= 0 intString objects],
   *        "tags": [>= 0 Strings],
   *        "contact_id": int
   *      }
   *    ],
   *    "is_human": bool,
   *    "contact_id": int
   *  }
   *
   * TODO Obviously the above map format should be in the docs/wiki, as it is
   * also highly relevant to Alice.
   */
  Contact.fromJson(Map json) {
    id = json['contact_id'];
    isHuman = json['is_human'];
    name = json['full_name'];

    if(json.containsKey('attributes')) {
      Map attributes = json['attributes'][0];

      _backupList          = new MiniboxList.fromJson(json, 'backup');
      _emailAddressList    = new MiniboxList.fromJson(json, 'emailaddresses');
      _handlingList        = new MiniboxList.fromJson(json, 'handling');
      _telephoneNumberList = new MiniboxList.fromJson(json, 'telephonenumbers');
      _workHoursList       = new MiniboxList.fromJson(json, 'workhours');

      department     = attributes['department'];
      info           = attributes['info'];
      position       = attributes['position'];
      relations      = attributes['relations'];
      responsibility = attributes['responsibility'];
    }

    // Adding some dummy calendar events
    Map foo = new Map();
    foo['calendar_events'] = new List();
    foo['calendar_events'].add({'start':'2013-12-20 10:00:00', 'stop':'2014-01-05 12:00:00', 'content':'${id} Kursus I Shanghai. Tjekker sin email.'});
    foo['calendar_events'].add({'start':'2013-05-01 08:00:00', 'stop':'2014-02-07 17:00:00', 'content':'${id} Jordomrejse'});
    _calendarEventList = new CalendarEventList.fromJson(foo, 'calendar_events');
  }

  /**
   * [Contact] null constructor.
   */
  Contact._null() {
    id = null;
    isHuman = null;
  }

  /**
   * Enables a [Contact] to sort itself compared to other contacts.
   */
  int compareTo(Contact other) => name.compareTo(other.name);

  /**
   * [Contact] as String, for debug/log purposes.
   */
  String toString() => '${name}-${id}-${isHuman}';
}
