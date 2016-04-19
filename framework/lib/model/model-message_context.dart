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
      : cid = map[Key.contactId],
        contactName = map[Key.contactName],
        rid = map[Key.receptionId],
        receptionName = map[Key.receptionName];

  /**
   * Creates a messagContext from a [ReceptionAttributes] object
   */
  MessageContext.fromContact(BaseContact contact, Reception reception) {
    cid = contact.id;
    contactName = contact.name;
    rid = reception.id;
    receptionName = reception.name;
  }

  /**
   * Returns a map representation of the object. Suitable for serialization.
   */
  Map toJson() => {
        Key.contactId: cid,
        Key.contactName: contactName,
        Key.receptionId: rid,
        Key.receptionName: receptionName
      };

  @override
  int get hashCode => contactString.hashCode;

  @override
  bool operator ==(MessageContext other) =>
      cid == other.cid && rid == other.rid;

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
