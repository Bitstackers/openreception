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

part of orf.model;

/// 'Enum' type representing the different types of messaging endpoints.
abstract class MessageEndpointType {
  static const String sms = 'sms';
  static const String emailTo = 'email-to';
  static const String emailCc = 'email-cc';
  static const String emailBcc = 'email-bcc';

  static const List<String> types = const <String>[
    sms,
    emailTo,
    emailCc,
    emailBcc
  ];
}

/// Model class for a messaging endpoint.
///
/// A messaging endpoint is any destination idenfier that supports
/// message delivery. The known types of endpoints are identified
/// by [MessageEndpointType].
class MessageEndpoint {
  /// Type of endpoint. Must be one of [MessageEndpointType.types].
  String type = MessageEndpointType.emailTo;
  String name = '';
  String address = '';
  String note = '';

  /// Default empty constructor.
  MessageEndpoint.empty();

  /// Deserializing constructor.
  MessageEndpoint.fromMap(Map<String, dynamic> map) {
    type = map[key.type];
    name = map.containsKey(key.name) ? map[key.name] : '';
    address = map[key.address];
    note = map[key.note];
  }

  /// Deserializing factory
  static MessageEndpoint decode(Map<String, dynamic> map) =>
      new MessageEndpoint.fromMap(map);

  /// JSON encoding function.
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.type: type,
        key.address: address,
        key.name: name,
        key.note: note
      };

  /// Stringify the object.
  @override
  String toString() => '$type:$address';

  @override
  bool operator ==(Object other) =>
      other is MessageEndpoint &&
      this.type == other.type &&
      this.address == other.address;

  @override
  int get hashCode => toString().hashCode;
}
