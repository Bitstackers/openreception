/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

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

  Contact           get first    => _list.length > 0 ? _list.first : nullContact;
  Iterator<Contact> get iterator => _list.iterator;

  /**
   * [ContactList] constructor.
   */
  ContactList();

  /**
   * [ContactList] constructor. Builds a list of [Contact] objects from the
   * contents of json[key].
   */
  factory ContactList.fromJson(Map json, String key) {
    ContactList contactList = new ContactList();

    if (json.containsKey(key) && json[key] is List) {
      log.debug('model.ContactList.fromJson key: ${key} list: ${json[key]}');
      contactList = new ContactList._fromList(json[key]);
    } else {
      log.critical('model.ContactList.fromJson bad data key: ${key} map: ${json}');
    }

    return contactList;
  }

  /**
   * [ContactList] from list constructor.
   */
  ContactList._fromList(List<Map> list) {
    list.forEach((item) => _list.add(new Contact.fromJson(item)));
    _list.sort();

    log.debug('ContactList._internal build ContactList from ${list}');
  }

  /**
   * Return the [id] [Contact] or [nullContact] if [id] does not exist.
   */
  Contact getContact(int id) {
    log.debug('ContactList.getContact' + _list.fold('', (acc, item) => '${acc}, ${item}'));
    for(Contact contact in _list) {
      if(id == contact.id) {
        return contact;
      }
    }

    return nullContact;
  }
}
