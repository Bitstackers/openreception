/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of controller;

class Contact {
  final ORService.RESTContactStore _store;

  /**
   * Constructor.
   */
  Contact(this._store);

  /**
   * Fetch the [contactId] [ORModel.Contact].
   */
  Future<ORModel.BaseContact> get(int contactId) => _store.get(contactId);

  /**
   * Return all the [Model.Contact]'s that belong to [rRef].
   */
  Future<Iterable<ORModel.ReceptionContact>> list(
      ORModel.ReceptionReference rRef) async {
    final crefs = await _store.receptionContacts(rRef.id);

    List<ORModel.ReceptionContact> contacts = [];
    await Future.forEach(crefs, (cRef) async {
      contacts.add(new ORModel.ReceptionContact(
          await _store.get(cRef.id), await _store.data(cRef.id, rRef.id)));
    });


    return contacts;
  }
}
