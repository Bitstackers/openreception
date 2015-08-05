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

abstract class MessageContextJSONKey {
  static const Reception = 'reception';
  static const Contact = 'contact';
  static const ID = 'id';
  static const Name = 'name';
}

class MessageContext {

  final String className = libraryName + "MessageContext";

  /* Private fields */
  int _contactID;
  int _receptionID;
  String _contactName;
  String _receptionName;

  /* Getters and setters, chunk-o-boilerplate code. */
  int    get contactID                      => this._contactID;
         set contactID (int newID)          => this._contactID = newID;
  String get contactName                    => this._contactName;
         set contactName (String newName)   => this._contactName = newName;
  int    get receptionID                    => this._receptionID;
         set receptionID (int newID)        => this._receptionID = newID;
  String get receptionName                  => this._receptionName;
         set receptionName (String newName) => this._receptionName = newName;

  /**
   * Default constructor.
   */
  MessageContext();

  /**
   * Constructor. Deserializes the object from Map representation.
   */
  MessageContext.fromMap(Map map) {
    this..contactID =
          map[MessageContextJSONKey.Contact][MessageContextJSONKey.ID]
        ..contactName =
          map[MessageContextJSONKey.Contact][MessageContextJSONKey.Name]
        ..receptionID =
          map[MessageContextJSONKey.Reception][MessageContextJSONKey.ID]
        ..receptionName =
          map[MessageContextJSONKey.Reception][MessageContextJSONKey.Name];
  }

  /**
   * Creates a messagContext from a [Contact] object
   */
  MessageContext.fromContact(Contact contact, Reception reception) {
    this.contactID = contact.ID;
    this.contactName = contact.fullName;
    this.receptionID = reception.ID;
    this.receptionName = reception.name;
  }

  /**
   * Returns a map representation of the object. Suitable for serialization.
   */
  Map get asMap => {
    'contact'   : {
      'id'  : this.contactID,
      'name': this.contactName
    },
    'reception' : {
      'id'  : this.receptionID,
      'name': this.receptionName
    }
  };

  /**
   * TODO: Change contactID and receptionID to use the constants from shared model classes.
   */
  void validate() {
    if (this.contactID   == null || this.contactID   == 0 ||
        this.receptionID == null || this.receptionID == 0) {
      throw new ArgumentError.value
        (this.asMap, 'validate', 'Failed to validate');
    }
  }

  Map toJson () => this.asMap;

  @override
  int get hashCode {
    return (this.contactString).hashCode;
  }

  @override
  bool operator ==(MessageRecipient other) => this.contactID   == other.contactID &&
                                              this.receptionID == other.receptionID;

  String get contactString => contactID.toString() + "@" + receptionID.toString();

  @override
  String toString() => '${this.contactString} - ${this.contactName}@${this.receptionName}';

}
