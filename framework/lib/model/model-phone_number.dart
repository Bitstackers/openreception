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

part of openreception.framework.model;

/**
 * A model class repsenting a phone number that can be associated with a
 * contact.
 */
class PhoneNumber {
  String get destination => _destination;
  String _destination = '';
  bool confidential = false;
  String note = '';

  void set destination(String newDestination) {
    try {
      int.parse(_normalize(newDestination));
    } on FormatException {
      throw new ArgumentError.value(
          newDestination, 'newDestination', 'Contains invalid characters');
    }

    _destination = newDestination;
  }

  String get normalizedDestination => _normalize(destination);

  String _normalize(String str) => str.replaceAll(' ', '').replaceAll('+', '');

  /**
   * Deserializing constructor.
   */
  PhoneNumber.fromMap(Map map)
      : note = map[Key.note],
        _destination = map[Key.destination],
        confidential = map[Key.confidential];

  /**
   *
   */
  static PhoneNumber decode(Map map) => new PhoneNumber.fromMap(map);

  /**
   * A phone number is, by this definition, equal to another phone number, if
   * both their endpoint and type is the same.
   */
  @override
  bool operator ==(Object other) =>
      other is PhoneNumber &&
      normalizedDestination.toLowerCase() ==
          other.normalizedDestination.toLowerCase();

  /**
   * Default empty constructor.
   */
  PhoneNumber.empty();

  /**
   * Map representation of the object. Serialization function.
   */
  Map toJson() => {
        Key.destination: destination,
        Key.confidential: confidential,
        Key.note: note
      };
}
