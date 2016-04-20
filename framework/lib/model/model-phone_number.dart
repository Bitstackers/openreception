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

part of openreception.model;

/**
 * A model class repsenting a phone number that can be associated with a
 * contact.
 */
class PhoneNumber {
  String destination = '';
  ///TODO: Rename to note.
  String description = '';

  Set<String> _tags = new Set<String>();
  Iterable<String> get tags => _tags;

  void set tags(Iterable<String> ts) {
    _tags = new Set<String>.from(ts);
  }

  bool confidential = false;

  /**
   * Deserializing constructor.
   */
  PhoneNumber.fromMap(Map map)
      : description = map[Key.description],
        destination = map[Key.destination],
        confidential = map[Key.confidential],
        _tags = new Set<String>.from(map[Key.tags] as List<String>);

  /**
   *
   */
  static PhoneNumber decode(Map map) => new PhoneNumber.fromMap(map);

  /**
   * A phone number is, by this definition, equal to another phone number, if
   * both their endpoint and type is the same.
   */
  @override
  bool operator ==(PhoneNumber other) =>
      destination.toLowerCase() == other.destination.toLowerCase();

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
        Key.description: description,
        Key.tags: tags.toList(growable: false)
      };
}
