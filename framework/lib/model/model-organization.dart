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
 * Validate an organization before and after serializing and deserializing.
 * Put any constraints that must hold at these times in this function.
 */
List<FormatException> validateOrganization(Organization org) {
  List<FormatException> errors = [];

  if (org.id == null) {
    errors.add(new FormatException('uuid is null'));
  }

  if (org.name == null) {
    errors.add(new FormatException('name is null'));
  }

  if (org.name.isEmpty) {
    errors.add(new FormatException('name is empty'));
  }

  if (org.billingType == null) {
    errors.add(new FormatException('billingType is null'));
  }

  if (org.flags == null) {
    errors.add(new FormatException('flags is null'));
  }

  return errors;
}

/**
 * Class representing an organization.
 */
class Organization {
  static const int noId = 0;

  int id = noId;
  String name = '';
  String billingType = '';
  List<String> flags = [];

  /**
   * Default empty constructor.
   */
  Organization.empty();

  /**
   * Constructor used in serializing.
   */
  Organization.fromMap(Map map)
      : id = map[Key.id],
        name = map[Key.name],
        billingType = map[Key.billingType],
        flags = map[Key.flags];

  /**
   * Deserializing factor.
   */
  static Organization decode(Map map) => new Organization.fromMap(map);

  OrganizationReference get reference => new OrganizationReference(id, name);

  /**
   * Returns a Map representation of the Organization.
   * Serialization function.
   */
  Map toJson() => {
        Key.id: id,
        Key.billingType: billingType,
        Key.flags: flags,
        Key.name: name
      };
}
