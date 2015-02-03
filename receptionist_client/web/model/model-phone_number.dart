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

class PhoneNumber {
  int    _phoneID;
  int    _priority;
  String _value;
  String _kind;
  String _description;

  int    get phoneID     => _phoneID;
  int    get priority    => _priority;
  String get kind        => _kind;
  String get value       => _value;
  String get description => _description;

  int compareTo(PhoneNumber other) => priority - other.priority;

  PhoneNumber ();

  PhoneNumber.fromMap(Map map) {
    this._value       = map['value'];
    this._kind        = map['kind'];
    this._phoneID     = map['id'];
    this._priority    = map['priority'];
    this._description = map['description'];

    if (this._priority == null) {
      this._priority = 0;
    }
  }

  @override
  String toString () {
    return '${this.kind}:${this.value}, ID: ${this.phoneID}, priority: ${this.priority}' ;
  }
}

class DiablePhoneNumber extends PhoneNumber {
  int    _contactID;
  int    _receptionID;

  int get contactID   => _contactID;
  int get receptionID => _receptionID;

  int compareTo(PhoneNumber other) => this.priority - other.priority;

  DiablePhoneNumber.from(PhoneNumber number, Contact context) {
    this._value    = number._value;
    this._kind     = number._kind;
    this._phoneID  = number._phoneID;
    this._priority = number._priority;

    this._contactID   = context.ID;
    this._receptionID = context.receptionID;
  }

  String toLabel () {
    return '${this.value}';
  }

  @override
  String toString () {
    return '${super.toString()}, context:${contactID}@${receptionID}';
  }

}