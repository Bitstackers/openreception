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
 * 'Enum' type representing the different types of messaging endpoints.
 */
abstract class MessageEndpointType {
  static const String sms = 'sms';
  static const String email = 'email';

  static const List<String> types = const [sms, email];
}

/**
 * Model class for a messaging endpoint. A messaging endpoint is any
 * destination idenfier that supports message delivery. The known types of
 * endpoints are identified by [MessageEndpointType].
 */
class MessageEndpoint {
  static const int noId = 0;
  int id = noId;

  /// Type of endpoint. Must be one of [MessageEndpointType].
  String type = MessageEndpointType.email;
  String address;
  String description;
  bool confidential;
  bool enabled;

  String role = Role.TO;
  String name = '';

  /**
   * Default empty constructor.
   */
  MessageEndpoint.empty();

  /**
   * Deserializing constructor.
   */
  MessageEndpoint.fromMap(Map map) {
    id = map[Key.id];
    type = map[Key.type];

    address = map[Key.address];
    confidential = map[Key.confidential];
    description = map[Key.description];

    name = map.containsKey(Key.name) ? map[Key.name] : '';
    role = map.containsKey(Key.role) ? map[Key.role] : Role.TO;

    enabled = map[Key.enabled];
  }

  /**
   * Deserializing factory
   */
  static MessageEndpoint decode(Map map) => new MessageEndpoint.fromMap(map);

  /**
   * JSON encoding function.
   */
  Map toJson() => this.asMap;

  /**
   * Map representation of the object.
   */
  Map get asMap => {
        Key.id: id,
        Key.type: type,
        Key.address: address,
        Key.confidential: confidential,
        Key.enabled: enabled,
        Key.description: description,
        Key.name: name,
        Key.role: role
      };

  /**
   * Stringify the object.
   */
  @override
  String toString() => '$type:$address';

  /**
   *
   */
  @override
  bool operator ==(MessageEndpoint other) =>
      this.type == other.type && this.address == other.address;
}
