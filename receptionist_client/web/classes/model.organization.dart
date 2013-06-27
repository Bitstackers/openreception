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
 * TODO comment
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
   *  {
   *    "full_name": String,
   *    "customertype": String,
   *    "addresses": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ],
   *    "organization_id": int,
   *    "crapcallhandling": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ],
   *    "greeting": String,
   *    "websites": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ],
   *    "telephonenumbers": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ],
   *    "product": String,
   *    "handlings": [
   *      {
   *        "priority": int,
   *        "value": String
   *      },
   *    ],
   *    "emailaddresses": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ],
   *    "alternatenames": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ],
   *    "other": String,
   *    "bankinginformation": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ],
   *    "uri": String,
   *    "contacts": [....],
   *    "openinghours": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ],
   *    "registrationnumbers": [
   *      {
   *        "priority": int,
   *        "value": String
   *      }, ....
   *    ]
   *  }
   *
   * TODO Obviously the above map format should be in the docs/wiki, as it is
   * also highly relevant to Alice.
   */
  Organization(Map json) {
    if(json.containsKey('addresses')) {
      _addressList = new MiniboxList(json['addresses']);
    } else {
      // Log bad json? Check schema somewhere else?
    }

    if(json.containsKey('alternatenames')) {
      _alternateNameList = new MiniboxList(json['alternatenames']);
    }

    if(json.containsKey('bankinginformation')) {
      _bankingInformationList = new MiniboxList(json['bankinginformation']);
    }

    if(json.containsKey('contacts')) {
      _contactList = new ContactList(json['contacts']);
    }

    if(json.containsKey('crapcallhandling')) {
      _crapcallHandlingList = new MiniboxList(json['crapcallhandling']);
    }

    if(json.containsKey('emailaddresses')) {
      _emailAddressList = new MiniboxList(json['emailaddresses']);
    }

    if(json.containsKey('handlings')) {
      _handlingList = new MiniboxList(json['handlings']);
    }

    if(json.containsKey('openinghours')) {
      _openingHoursList = new MiniboxList(json['openinghours']);
    }

    if(json.containsKey('registrationnumbers')) {
      _registrationNumberList = new MiniboxList(json['registrationnumbers']);
    }

    if(json.containsKey('telephonenumbers')) {
      _telephoneNumberList = new MiniboxList(json['telephonenumbers']);
    }

    if(json.containsKey('websites')) {
      _websiteList = new MiniboxList(json['websites']);
    }

    customerType = json['customertype'];
    greeting = json['greeting'];
    id = json['organization_id'];
    name = json['full_name'];
    other = json['other'];
    product = json['product'];

    // Add some dummy calendar events
    List tempEvents = new List();
    tempEvents.add({'start':'2013-05-17 07:37:16', 'stop':'2013-05-17 17:00:00', 'content':'${id} Salgsmøde'});
    tempEvents.add({'start':'2013-12-20 10:00:00', 'stop':'2014-01-05 12:00:00', 'content':'${id} Kursus'});
    tempEvents.add({'start':'2013-02-07 08:30:16', 'stop':'2014-02-07 14:45:00', 'content':'${id} Ombygning af bygning der er alt for varm, og derfor ikke virker efter hensigten'});
    _calendarEventList = new CalendarEventList(tempEvents);
  }

  Organization._null();

  int compareTo(Organization other) => name.compareTo(other.name);

  String toString() => '${name}-${id}';
}
