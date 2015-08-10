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
  static const String SMS = 'sms';
  static const String EMAIL = 'email';

  static const List<String> types = const [SMS, EMAIL];
}

/**
 * Model class for a messaging endpoint. A messaging endpoint is any
 * destination idenfier that supports message delivery. The known types of
 * endpoints are identified by [MessageEndpointType].
 */
class MessageEndpoint {

  /// Type of endpoint. Must be one of [MessageEndpointType].
  String type;
  String address;
  String description;
  bool confidential;
  bool enabled;

  @deprecated
  MessageRecipient recipient = null;

  /**
   * Default empty constructor.
   */
  MessageEndpoint.empty();

  /**
   * Deserializing constructor.
   */
  MessageEndpoint.fromMap(Map map) {
    type = map[Key.type];

    address = map[Key.address];
    confidential = map[Key.confidential];
    description = map[Key.description];

    enabled = map[Key.enabled];
    if (map.containsKey('recipient')) {
      recipient = new MessageRecipient.fromMap(map['recipient']);
    }
  }

  /**
   * JSON encoding function.
   */
  Map toJson() => this.asMap;

  /**
   * Map representation of the object.
   */
  Map get asMap => {
    Key.type: type,
    Key.address: address,
    Key.confidential: confidential,
    Key.enabled: enabled,
    Key.description: description,
  };

  /**
   * Stringify the object.
   */
  @override
  String toString() => '$type:$address';
}
