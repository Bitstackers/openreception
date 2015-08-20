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

  final String className = libraryName + "MessageContext";

  int contactID = 0;
  int receptionID = 0;
  String contactName = '';
  String receptionName = '';

  /**
   * Default constructor.
   */
  @deprecated
  MessageContext();

  /**
   * Default empty constructor.
   */
  MessageContext.empty();

  /**
   * Constructor. Deserializes the object from Map representation.
   */
  MessageContext.fromMap(Map map) {
    this..contactID =
          map[Key.contact][Key.ID]
        ..contactName =
          map[Key.contact][Key.name]
        ..receptionID =
          map[Key.reception][Key.ID]
        ..receptionName =
          map[Key.reception][Key.name];
  }

  /**
   * Creates a messagContext from a [Contact] object
   */
  MessageContext.fromContact(Contact contact, Reception reception) {
    contactID = contact.ID;
    contactName = contact.fullName;
    receptionID = reception.ID;
    receptionName = reception.name;
  }

  /**
   * Returns a map representation of the object. Suitable for serialization.
   */
  Map get asMap => {
    'contact'   : {
      'id'  : contactID,
      'name': contactName
    },
    'reception' : {
      'id'  : receptionID,
      'name': receptionName
    }
  };

  Map toJson () => this.asMap;

  @override
  int get hashCode {
    return (this.contactString).hashCode;
  }

  @override
  bool operator ==(DistributionListEntry other) => this.contactID   == other.contactID &&
                                              this.receptionID == other.receptionID;

  String get contactString => contactID.toString() + "@" + receptionID.toString();

  @override
  String toString() => '${this.contactString} - ${this.contactName}@${this.receptionName}';

}
