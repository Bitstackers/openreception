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

final Reception nullReception = new Reception._null();

/**
 * A [BasicReception] does only contains [ID] and [name].
 */
class BasicReception implements Comparable{
  int    _ID   = 0;
  String _name = '';

  int    get ID   => _ID;
  String get name => _name;

  /**
   * [BasicReception] constructor. Expects a map in the following format:
   *
   *  {
   *    "full_name": String,
   *    "reception_id": int
   *  }
   *
   * TODO Obviously the above map format should be in the docs/wiki, as it is
   * also highly relevant to Alice.
   */
  BasicReception.fromJson(Map json) {
    _ID   = json['reception_id'];
    _name = json['full_name'];
  }

  /**
   * [BasicReception] null constructor.
   */
  BasicReception._null();

  /**
   * Enables a [BasicReception] to sort itself based on its [name].
   */
  int compareTo(BasicReception other) => name.compareTo(other.name);

  /**
   * [Reception] as String, for debug/log purposes.
   */
  String toString() => '${name}-${ID}';
}

/**
 * An [Reception]. Sorting receptions is done based on [name].
 */
class Reception extends BasicReception{
  MiniboxList       _addressList            = new MiniboxList();
  MiniboxList       _alternateNameList      = new MiniboxList();
  MiniboxList       _bankingInformationList = new MiniboxList();
  CalendarEventList _calendarEventList      = new CalendarEventList();
  ContactList       _contactList            = new ContactList();
  String            _customerType           = '';
  MiniboxList       _crapcallHandlingList   = new MiniboxList();
  MiniboxList       _emailAddressList       = new MiniboxList();
  String            _greeting               = '';
  MiniboxList       _handlingList           = new MiniboxList();
  MiniboxList       _openingHoursList       = new MiniboxList();
  String            _other                  = '';
  String            _product                = '';
  MiniboxList       _registrationNumberList = new MiniboxList();
  MiniboxList       _telephoneNumberList    = new MiniboxList();
  MiniboxList       _websiteList            = new MiniboxList();

  MiniboxList         get addressList            => _addressList;
  MiniboxList         get alternateNameList      => _alternateNameList;
  MiniboxList         get bankingInformationList => _bankingInformationList;
  Future<ContactList> get contactList            => storage.Contact.list(this.ID);
  Future<CalendarEventList> get calendarEventList => storage.Reception.calendar(this.ID);
  MiniboxList         get crapcallHandlingList   => _crapcallHandlingList;
  String              get customerType           => _customerType;
  MiniboxList         get emailAddressList       => _emailAddressList;
  String              get greeting               => _greeting;
  MiniboxList         get handlingList           => _handlingList;
  MiniboxList         get openingHoursList       => _openingHoursList;
  String              get other                  => _other;
  String              get product                => _product;
  MiniboxList         get registrationNumberList => _registrationNumberList;
  MiniboxList         get telephoneNumberList    => _telephoneNumberList;
  MiniboxList         get websiteList            => _websiteList;

  static Reception _currentReception = nullReception;
  
  static Reception get currentReception                       =>  _currentReception;
  static           set currentReception (Reception reception) {
    _currentReception = reception;
    event.bus.fire(event.receptionChanged, reception);
  }
  
  static Future<Reception> get (int receptionID) {
    return Service.Reception.get(receptionID);
  }
  
  /**
   * [Reception] constructor. Expects a map in the following format:
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
   *    "reception_id": int,
   *    "crapcallhandling": [>= 0 intString objects],
   *    "greeting": String,
   *    "websites": [>= 0 intString objects],
   *    "telephonenumbers": [>= 0 intString objects],
   *    "product": String,
   *    "handlings": [>= 0 intString objects],
   *    "emailaddresses": [>= 0 intString objects],
   *    "alternatenames": [>= 0 intString objects],
   *    "other": String,
   *    "bankinginformation": [>= 0 intString objects]
   *    "contacts": [>= 0 Contact JSON objects],
   *    "openinghours": [>= 0 intString objects],
   *    "registrationnumbers": [>= 0 intString objects]
   *  }
   *
   * TODO Obviously the above map format should be in the docs/wiki, as it is
   * also highly relevant to Alice.
   */
  Reception.fromJson(Map json) : super.fromJson(json) {
    _addressList            = new MiniboxList.fromJson(json, 'addresses');
    _alternateNameList      = new MiniboxList.fromJson(json, 'alternatenames');
    _bankingInformationList = new MiniboxList.fromJson(json, 'bankinginformation');
    _crapcallHandlingList   = new MiniboxList.fromJson(json, 'crapcallhandling');
    _customerType           = json['customertype'];
    _emailAddressList       = new MiniboxList.fromJson(json, 'emailaddresses');
    _greeting               = json['greeting'];
    _handlingList           = new MiniboxList.fromJson(json, 'handlings');
    _openingHoursList       = new MiniboxList.fromJson(json, 'openinghours');
    _other                  = json['other'];
    _product                = json['product'];
    _registrationNumberList = new MiniboxList.fromJson(json, 'registrationnumbers');
    _telephoneNumberList    = new MiniboxList.fromJson(json, 'telephonenumbers');
    _websiteList            = new MiniboxList.fromJson(json, 'websites');
  }

  /**
   * [Reception] null constructor.
   */
  Reception._null() : super._null();
}
