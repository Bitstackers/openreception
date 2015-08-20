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

  String role = '';
  String name;
  String type;
  String address;

  /**
   * Default constructor.
   */
  MessageRecipient(MessageEndpoint ep, DistributionListEntry de) {
    role = de.role;
    name = '${de.contactName} (${de.receptionName})';
    type = ep.type;
    address = ep.address;
  }


  /**
   * Default empty constructor.
   */
  MessageRecipient.empty();

  /**
   * Parsing constructor.
   */
  MessageRecipient.fromMap(Map map) {
    role = map[Key.role];
    name = map[Key.name];
    type = map[Key.type];
    address = map[Key.address];
  }

  /**
   * Returns a map representation of the object. Suitable for serialization.
   */
  Map get asMap =>
      {Key.role: role, Key.name: name, Key.type: type, Key.address: address};

  /**
   * Deserializing factory constructor.
   */
  static MessageRecipient decode(Map map) => new MessageRecipient.fromMap(map);

  /**
   * String representation of object.
   */
  String toString() => '${role}: <${name}>$type:$address';

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
  int get hashCode => '$type:$address'.hashCode;

}
