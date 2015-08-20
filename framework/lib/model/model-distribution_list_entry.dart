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

class DistributionListEntry {
  static const int noId = 0;

  ///Database ID
  int id = noId;
  String role = '';
  int contactID;
  int receptionID;
  String contactName;
  String receptionName;

  /**
   * Default constructor.
   */
  DistributionListEntry();

  DistributionListEntry.empty();

  /**
   * Parsing constructor. Takes in an object similar to MessageContext, with the
   * exception of having an extra 'role' field.
   * TODO: Check if role is ever passed to this constructor, and eliminate it
   * otherwise.
   */
  DistributionListEntry.fromMap(Map map, {String role: Role.TO}) {
    contactID = map[Key.contact][Key.ID];
    contactName = map[Key.contact][Key.name];
    receptionID = map[Key.reception][Key.ID];
    receptionName = map[Key.reception][Key.name];
    id = map[Key.ID];

    if (map.containsKey(Key.role)) {
      this.role = map[Key.role];
    }
  }

  /**
   * Returns a map representation of the object. Suitable for serialization.
   */
  Map get asMap => {
    Key.ID: id,
    Key.role: role,
    Key.contact: {Key.ID: contactID, Key.name: contactName},
    Key.reception: {Key.ID: receptionID, Key.name: receptionName},
  };

  /**
   * Deserializing factory constructor.
   */
  static DistributionListEntry decode(Map map) =>
      new DistributionListEntry.fromMap(map);

  /**
   * Serialization function
   */
  Map toJson() => this.asMap;

  /**
   * String representation of object.
   */
  String toString() => 'id:${id}, role:$role, '
      '$contactID@$receptionID ($contactName@$receptionName)';

  /**
   *
   */
  @override
  bool operator ==(DistributionListEntry other) =>
      this.contactID == other.contactID &&
          this.receptionID == other.receptionID;
}
