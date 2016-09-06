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

class MessageContext {
  int cid = BaseContact.noId;
  int rid = Reception.noId;
  String contactName = '';
  String receptionName = '';

  /// Default empty constructor.
  MessageContext.empty();

  /// Default deserializing constructor.
  ///
  /// Deserializes the object from Map representation.
  MessageContext.fromMap(Map<String, dynamic> map)
      : cid = map[key.cid],
        contactName = map[key.contactName],
        rid = map[key.rid],
        receptionName = map[key.receptionName];

  /// Creates a messagContext from a [ReceptionAttributes] object
  MessageContext.fromContact(BaseContact contact, ReceptionReference rRef) {
    cid = contact.id;
    contactName = contact.name;
    rid = rRef.id;
    receptionName = rRef.name;
  }

  bool get isEmpty => cid == BaseContact.noId && rid == Reception.noId;

  /// Returns a map representation of the object.
  ///
  /// Suitable for serialization.
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.cid: cid,
        key.contactName: contactName,
        key.rid: rid,
        key.receptionName: receptionName
      };

  @override
  int get hashCode => contactString.hashCode;

  @override
  bool operator ==(Object other) =>
      other is MessageContext && cid == other.cid && rid == other.rid;

  String get contactString => '$cid@$rid';

  @override
  String toString() => '$contactString - $contactName@$receptionName';
}
