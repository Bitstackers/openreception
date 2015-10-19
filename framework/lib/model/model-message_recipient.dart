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

class MessageRecipient {
  String address;
  String contactName;
  String receptionName;
  String role = '';
  String type;

  /**
   * Constructor.
   */
  MessageRecipient(MessageEndpoint ep, DistributionListEntry de) {
    address = ep.address;
    contactName = de.contactName;
    receptionName = de.receptionName;
    role = de.role;
    type = ep.type;
  }

  /**
   * Empty constructor.
   */
  MessageRecipient.empty();

  /**
   * Parsing constructor.
   */
  MessageRecipient.fromMap(Map map) {
    address = map[Key.address];
    contactName = map[Key.contactName];
    receptionName = map[Key.receptionName];
    role = map[Key.role];
    type = map[Key.type];
  }

  /**
   * Returns a map representation of the object. Suitable for serialization.
   */
  Map get asMap => {
        Key.address: address,
        Key.contactName: contactName,
        Key.receptionName: receptionName,
        Key.role: role,
        Key.type: type
      };

  /**
   * Deserializing factory constructor.
   */
  static MessageRecipient decode(Map map) => new MessageRecipient.fromMap(map);

  /**
   * String representation of object.
   */
  String toString() => '${role}: <${contactName}>${type}:${address}';

  /**
   * JSON serialization function
   */
  Map toJson() => this.asMap;

  /**
   *
   */
  @override
  bool operator ==(MessageRecipient other) =>
      this.type == other.type && this.address == other.address;

  @override
  int get hashCode => '${type}:${address}'.toLowerCase().hashCode;
}
