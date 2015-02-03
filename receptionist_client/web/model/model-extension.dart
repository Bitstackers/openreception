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

class Extension {

  final String _value;

  static final nullExtension = new Extension._null();

  static Extension _selectedExtension = nullExtension;

  static final EventType<Extension> activeExtensionChanged = new EventType<Extension>();

  static Extension get selectedExtension                       =>  _selectedExtension;
  static           set selectedExtension (Extension extension) {
    _selectedExtension = extension;
    event.bus.fire(activeExtensionChanged, _selectedExtension);
  }

  Extension (this._value);

  Extension._null ([this._value = ""]);

  String get dialString {
    return this._value;
  }

  bool get valid => this != nullExtension && this._value.length > 1;
}