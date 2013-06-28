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

final Organization nullOrganization = new Organization._null();

/**
 * An [Organization]. Sorting organizations is done based on [name].
 */
class Organization implements Comparable{
  MiniboxList _addressList = nullMiniboxList;
  MiniboxList _alternateNameList = nullMiniboxList;
  MiniboxList _bankingInformationList = nullMiniboxList;
  ContactList _contactList = nullContactList;
  CalendarEventList _calendarEventList = nullCalendarEventList;
  MiniboxList _crapcallHandlingList = nullMiniboxList;
  MiniboxList _emailAddressList = nullMiniboxList;
  MiniboxList _handlingList = nullMiniboxList;
  MiniboxList _openingHoursList = nullMiniboxList;
  MiniboxList _registrationNumberList = nullMiniboxList;
  MiniboxList _telephoneNumberList = nullMiniboxList;
  MiniboxList _websiteList = nullMiniboxList;

  String customerType = '';
  String greeting = '';
  int id = -1;
  String name = '';
  String other = '';
  String product = '';

  MiniboxList       get addressList => _addressList;
  MiniboxList       get alternateNameList => _alternateNameList;
  MiniboxList       get bankingInformationList => _bankingInformationList;
  ContactList       get contactList => _contactList;
  CalendarEventList get calendarEventList => _calendarEventList;
  MiniboxList       get crapcallHandlingList => _crapcallHandlingList;
  MiniboxList       get emailAddressList => _emailAddressList;
  MiniboxList       get handlingList => _handlingList;
  MiniboxList       get openingHoursList => _openingHoursList;
  MiniboxList       get registrationNumberList => _registrationNumberList;
  MiniboxList       get telephoneNumberList => _telephoneNumberList;
  MiniboxList       get websiteList => _websiteList;

  /**
   * [Organization] constructor. Expects a map in the following format:
   *
   * intString JSON object =
   *  {
   *    "priority": int,
   *    "value": String
   *  }
   *
   *  {
   *    "full_name": String,
   *    "customertype": String,
   *    "addresses": [>= 0 intString objects],
   *    "organization_id": int,
   *    "crapcallhandling": [>= 0 intString objects],
   *    "greeting": String,
   *    "websites": [>= 0 intString objects],
   *    "telephonenumbers": [>= 0 intString objects],
   *    "product": String,
   *    "handlings": [>= 0 intString objects],
   *    "emailaddresses": [>= 0 intString objects],
   *    "alternatenames": [>= 0 intString objects],
   *    "other": String,
   *    "bankinginformation": [>= 0 intString objects],
   *    "uri": String,
   *    "contacts": [>= 0 Contact JSON objects],
   *    "openinghours": [>= 0 intString objects],
   *    "registrationnumbers": [>= 0 intString objects]
   *  }
   *
   * TODO Obviously the above map format should be in the docs/wiki, as it is
   * also highly relevant to Alice.
   */
  Organization.fromJson(Map json) {
    _addressList            = new MiniboxList.fromJson(json, 'addresses');
    _alternateNameList      = new MiniboxList.fromJson(json, 'alternatenames');
    _bankingInformationList = new MiniboxList.fromJson(json, 'bankinginformation');
    _contactList            = new ContactList.fromJson(json, 'contacts');
    _crapcallHandlingList   = new MiniboxList.fromJson(json, 'crapcallhandling');
    _emailAddressList       = new MiniboxList.fromJson(json, 'emailaddresses');
    _handlingList           = new MiniboxList.fromJson(json, 'handlings');
    _openingHoursList       = new MiniboxList.fromJson(json, 'openinghours');
    _registrationNumberList = new MiniboxList.fromJson(json, 'registrationnumbers');
    _telephoneNumberList    = new MiniboxList.fromJson(json, 'telephonenumbers');
    _websiteList            = new MiniboxList.fromJson(json, 'websites');

    customerType = json['customertype'];
    greeting     = json['greeting'];
    id           = json['organization_id'];
    name         = json['full_name'];
    other        = json['other'];
    product      = json['product'];

    // Adding some dummy calendar events
    Map foo = new Map();
    foo['calendar_events'] = new List();
    foo['calendar_events'].add({'start':'2013-05-17 07:37:16', 'stop':'2013-05-17 17:00:00', 'content':'${id} Salgsmøde'});
    foo['calendar_events'].add({'start':'2013-12-20 10:00:00', 'stop':'2014-01-05 12:00:00', 'content':'${id} Kursus'});
    foo['calendar_events'].add({'start':'2013-02-07 08:30:16', 'stop':'2014-02-07 14:45:00', 'content':'${id} Ombygning af bygning der er alt for varm, og derfor ikke virker efter hensigten'});
    _calendarEventList = new CalendarEventList.fromJson(foo, 'calendar_events');
  }

  /**
   * [Organization] null constructor.
   */
  Organization._null();

  /**
   * Enables an [Organization] to sort itself compared to other organizations.
   */
  int compareTo(Organization other) => name.compareTo(other.name);

  /**
   * [Organization] as String, for debug/log purposes.
   */
  String toString() => '${name}-${id}';
}
