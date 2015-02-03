/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

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

class Recipient {

  Map _map = {'contact'   : { 'id'   : Contact.noContact.ID,
                              'name' : "<null contact>",
                             },
              'reception' : { 'id'   : Reception.noReception.ID,
                              'name' : "<null reception>",
                             },
              'role' : null};

  /* Data map mappings */
  int    get contactID                   => this._map['contact']['id'];
         set contactID (int ID)          => this._map['contact']['id'] = ID;
  String get contactName                 => this._map['contact']['name'];
         set contactName (String name)   => this._map['contact']['name'] = name;
  int    get receptionID                 => this._map['reception']['id'];
         set receptionID (int ID)        => this._map['reception']['id'] = ID;
  String get receptionName               => this._map['reception']['name'];
         set receptionName (String name) => this._map['reception']['name'] = name;
  String get role                        => this._map['role'];
         set role (String role)          => this._map['role'] = role;

  Recipient (String contact_reception, String role) {
    List<String> split = contact_reception.split('@');
    this.contactID = int.parse(split[0]);
    this.receptionID = int.parse(split[1]);
    this.role = role;
  }

  factory Recipient.fromJSONString (String json) => new  Recipient.fromMap(JSON.decode (json));

  Recipient.fromMap (Map map) {
    this.contactID     = map['contact']['id'];
    this.contactName   = map['contact']['name'];
    this.receptionID   = map['reception']['id'];
    this.receptionName = map['reception']['name'];
    this.role          = map['role'];
  }

  @override
  int get hashCode => (this.ContactString()).hashCode;

  @override
  bool operator == (Recipient other) => this.ContactString() == other.ContactString();

  Map get asMap => this._map;

  Map    toJson()   => this.asMap;

  @override
  String toString() => '${this.contactName}@${this.receptionName}';

  String ContactString() => contactID.toString() + "@" + receptionID.toString();
}
