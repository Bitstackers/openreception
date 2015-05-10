/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * A [Contact] object. Sorting contacts is done based on [name].
 */
class Contact extends ORModel.Contact implements Comparable{

  static const String className = '${libraryName}.Contact';

  static final Contact noContact = new Contact.empty();

  static Contact _selectedContact = Contact.noContact;

  static Bus<Contact> _contactChange = new Bus<Contact>();
  static Stream<Contact> get onContactChange => _contactChange.stream;

  static Contact get selectedContact => _selectedContact;
  static set selectedContact(Contact contact) {
    _selectedContact = contact;
    _contactChange.fire(_selectedContact);
  }

  Contact.fromMap(Map map) : super.fromMap (map);

  Contact.empty() : super.none() {
    this.ID         = ORModel.Contact.nullContact.ID;
    this.contactType= ORModel.Contact.nullContact.contactType;
  }

  /**
   * Enables a [Contact] to sort itself compared to other contacts.
   */
  int compareTo(Contact other) => this.fullName.compareTo(other.fullName);

  /**
   * [Contact] as String, for debug/log purposes.
   */
  String toString() => '${this.fullName}-${this.ID}-${this.contactType}';

  /**
   * Return the [id] [Contact] or [noContact] if [id] does not exist.
   */
  static Contact findContact(int id, List<Contact> list) {
    for(Contact contact in list) {
      if(id == contact.ID) {
        return contact;
      }
    }

    return Contact.noContact;
  }

  bool get isEmpty    => this.ID == noContact.ID;
  bool get isNotEmpty => this.ID != noContact.ID;

}
