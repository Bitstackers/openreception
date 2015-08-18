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

class MessageRecipient extends MessageContext {

  static const int noId = 0;

  int id = noId;
  String                role      = '';
  List<MessageEndpoint> endpoints = [];

  /**
   * Default constructor.
   */
  MessageRecipient();

  /**
   * Parsing constructor. Takes in an object similar to MessageContext, with the
   * exception of having an extra 'role' field.
   * TODO: Check if role is ever passed to this constructor, and eliminate it
   * otherwise.
   */
  MessageRecipient.fromMap(Map map, {String role : Role.TO}) : super.fromMap(map) {

    id = map[Key.ID];

    if (map.containsKey(Key.role)) {
      this.role = map[Key.role];
    }

    if (map.containsKey('endpoints')) {
      this.endpoints = (map['endpoints'] as List).map ((Map endpointMap) =>
          new MessageEndpoint.fromMap(endpointMap)..recipient = this).toList();
    }
  }

  /**
   * Map representation
   */
  Map get asMap => super.asMap..addAll({Key.ID : id, Key.role : role});

  /**
   * Deserializing factory constructor.
   */
  static MessageRecipient decode (Map map) =>
    new MessageRecipient.fromMap(map);

  /**
   * String representation of object.
   */
  String toString() => '${this.role}: ${super.toString()}, endpoints: ${this.endpoints}';

  /**
   *
   */
  @override
  bool operator ==(MessageRecipient other) => this.contactID   == other.contactID &&
                                              this.receptionID == other.receptionID;
}