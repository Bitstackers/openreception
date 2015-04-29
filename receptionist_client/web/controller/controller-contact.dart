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

  Contact (this._store);

  Future<Iterable<Model.ContactCalendarEntry>>
  getCalendar(Model.Contact contact) =>
    this._store.calendarMap(contact.ID, contact.receptionID)
      .then((Iterable<Map> collection) =>
        collection.map((Map map) =>
            new Model.ContactCalendarEntry.fromMap(map)));

  Future<Iterable<Model.Contact>> list(Model.Reception reception) =>
    this._store.listByReception(reception.ID)
      .then((Iterable<ORModel.Contact> contacts) =>
        contacts.map((ORModel.Contact contact) =>
          new Model.Contact.fromMap(contact.asMap)));
}
