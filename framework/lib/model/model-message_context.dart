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

part of openreception.framework.model;

class MessageContext {
  int cid = BaseContact.noId;
  int rid = Reception.noId;
  String contactName = '';
  String receptionName = '';

  /**
   * Default empty constructor.
   */
  MessageContext.empty();

  /**
   * Constructor. Deserializes the object from Map representation.
   */
  MessageContext.fromMap(Map map)
      : cid = map[Key.cid],
        contactName = map[Key.contactName],
        rid = map[Key.rid],
        receptionName = map[Key.receptionName];

  /**
   * Creates a messagContext from a [ReceptionAttributes] object
   */
  MessageContext.fromContact(BaseContact contact, ReceptionReference rRef) {
    cid = contact.id;
    contactName = contact.name;
    rid = rRef.id;
    receptionName = rRef.name;
  }

  bool get isEmpty => cid == BaseContact.noId && rid == Reception.noId;

  /**
   * Returns a map representation of the object. Suitable for serialization.
   */
  Map toJson() => {
        Key.cid: cid,
        Key.contactName: contactName,
        Key.rid: rid,
        Key.receptionName: receptionName
      };

  @override
  int get hashCode => contactString.hashCode;

  @override
  bool operator ==(Object other) =>
      other is MessageContext && cid == other.cid && rid == other.rid;

  /**
   *
   */
  String get contactString => '$cid@$rid';

  /**
   *
   */
  @override
  String toString() => '$contactString - $contactName@$receptionName';
}
