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

abstract class MessageEndpointType {
  static const String SMS   = 'sms';
  static const String EMAIL = 'email';
}

class MessageEndpoint {

  String type;
  String address;
  String description;
  bool   confidential;
  bool   enabled;

  //TODO: Check if this is still needed.
  MessageRecipient recipient = null;

  MessageEndpoint.empty();

  MessageEndpoint.fromMap(Map map) {
    /// Map validation.
    assert(['type','address'].every((String key) => map.containsKey(key)));
    this.type    = map['type'];

    this.address = map['address'];
    this.confidential = map['confidential'];
    this.description = map['description'];

    this.enabled = map['enabled'];
    if (map.containsKey('recipient')) {
      this.recipient = new MessageRecipient.fromMap(map['recipient']);
    }

  }

  Map toJson() => this.asMap;

  Map get asMap => {
        'type' : this.type,
        'address' : this.address,
        'confidential' : this.confidential,
        'enabled' : this.enabled,
        'description' : this.description
        };

  @override
  String toString() => '${this.type}:${this.address}';

}