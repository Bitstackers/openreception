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
  MiniboxList       _backupList          = new MiniboxList();
  CalendarEventList _calendarEventList   = new CalendarEventList();
  String            department           = '';
  MiniboxList       _emailAddressList    = new MiniboxList();
  MiniboxList       _handlingList        = new MiniboxList();
  int               id;
  String            info                 = '';
  bool              isHuman;
  String            name                 = '';
  String            position             = '';
  String            relations            = '';
  String            responsibility       = '';
  List<String>      _tags                = new List<String>();
  MiniboxList       _telephoneNumberList = new MiniboxList();
  MiniboxList       _workHoursList       = new MiniboxList();

  MiniboxList       get backupList          => _backupList;
  CalendarEventList get calendarEventList   => _calendarEventList;
  MiniboxList       get emailAddressList    => _emailAddressList;
  MiniboxList       get handlingList        => _handlingList;
  List<String>      get tags                => _tags;
  MiniboxList       get telephoneNumberList => _telephoneNumberList;
  MiniboxList       get workHoursList       => _workHoursList;

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

    _backupList          = new MiniboxList.fromJson(json, 'backup');
    _emailAddressList    = new MiniboxList.fromJson(json, 'emailaddresses');
    _handlingList        = new MiniboxList.fromJson(json, 'handling');
    _telephoneNumberList = new MiniboxList.fromJson(json, 'telephonenumbers');
    _workHoursList       = new MiniboxList.fromJson(json, 'workhours');

    department     = json['department'];
    info           = json['info'];
    position       = json['position'];
    relations      = json['relations'];
    responsibility = json['responsibility'];

    if(json.containsKey('tags')) {
      _tags = json['tags'];
    }
    
    // Adding some dummy calendar events
    Map foo = new Map();
    foo['calendar_events'] = new List();
    foo['calendar_events'].add({'start':'2013-11-01 08:00:00', 'stop':'2014-04-07 17:00:01', 'content':'${id} Måneomrejse'});
    foo['calendar_events'].add({'start':'2013-05-01 08:00:00', 'stop':'2014-02-07 17:00:00', 'content':'${id} Jordomrejse'});
    foo['calendar_events'].add({'start':'2013-12-20 10:00:00', 'stop':'2014-01-05 12:00:00', 'content':'${id} Kursus I Shanghai. Tjekker sin email.'});
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
