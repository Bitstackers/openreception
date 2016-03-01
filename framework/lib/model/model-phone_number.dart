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
  String description = '';
  String endpoint = '';
  bool confidential = false;
  List<String> tags = [];

  /**
   * Deserializing constructor.
   */
  PhoneNumber.fromMap(Map map)
      : description = map[Key.description],
        endpoint = map[Key.endpoint],
        confidential = map[Key.confidential],
        tags = map[Key.tags];

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
      endpoint.toLowerCase() == other.endpoint.toLowerCase();

  /**
   * Default empty constructor.
   */
  PhoneNumber.empty();

  /**
   * Map representation of the object. Serialization function.
   */
  Map toJson() => {
        Key.endpoint: endpoint,
        Key.confidential: confidential,
        Key.description: description,
        Key.tags: tags
      };
}
