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
 * Class representing an organization.
 */
class Organization {
  static const String className = '$libraryName.Organization';
  static final Logger log = new Logger(Organization.className);
  static const int noID = 0;

  int id = noID;
  String fullName = '';
  String billingType  = '';
  String flag  = '';

  /**
   * Default empty constructor.
   */
  Organization.empty();

  /**
   * Constructor used in serializing.
   */
  Organization.fromMap(Map organizationMap) {
    if (organizationMap == null) throw new ArgumentError('Null map');

    try {
      this
        ..id = organizationMap[Key.ID]
        ..billingType = organizationMap[Key.billingType]
        ..flag = organizationMap[Key.flag]
        ..fullName = organizationMap[Key.fullName];
    } catch (error, stacktrace) {
      log.severe('Parsing of organization failed.', error, stacktrace);
      throw new ArgumentError('Invalid data in map');
    }

    this.validate();
  }

  /**
   * Returns a Map representation of the Organization.
   */
  Map get asMap => {
    Key.ID: this.id,
    Key.billingType: this.billingType,
    Key.flag: this.flag,
    Key.fullName: this.fullName
  };

  /**
   * Validate an organization before and after serializing and deserializing.
   * Put any constraints that must hold at these times in this function.
   */
  void validate() {}

  /**
   * Serialization function.
   */
  Map toJson() => this.asMap;
}
