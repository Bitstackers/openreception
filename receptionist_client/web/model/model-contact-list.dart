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
 * A list of [Contact] objects.
 */
class ContactList extends IterableBase<Contact>{
  List<Contact> _list = new List<Contact>();

  Contact           get first    => _list.length > 0 ? _list.first : Contact.noContact;
  Iterator<Contact> get iterator => _list.iterator;

  /**
   * [ContactList] constructor.
   */
  ContactList();

  /**
   * [ContactList] constructor. Builds a list of [Contact] objects from the
   * elements in the Contact list supplied.
   */
  factory ContactList.fromJson(List<ORModel.Contact> json, int receptionID) =>
    new ContactList._fromList(json, receptionID);


  factory ContactList.emptyList() {
    return new ContactList();
  }

  /**
   * [ContactList] from list constructor.
   */
  ContactList._fromList(List<ORModel.Contact> list, int receptionID) {
    list.forEach((item) => _list.add((item..receptionID = receptionID) as Contact));
    _list.sort();
  }

  /**
   * Return the [id] [Contact] or [nullContact] if [id] does not exist.
   */
  Contact getContact(int id) {
    for(Contact contact in _list) {
      if(id == contact.ID) {
        return contact;
      }
    }

    return Contact.noContact;
  }
}
