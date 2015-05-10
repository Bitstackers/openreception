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
   * Save [entry] to the database.
   */
  Future createCalendarEvent (Model.ContactCalendarEntry entry) =>
      _store.calendarEventCreate (entry);

  /**
   * Delete [entry] from the database.
   */
  Future deleteCalendarEvent (Model.ContactCalendarEntry entry) =>
      _store.calendarEventRemove (entry);

  /**
   * Return all the [contact] [Model.ContactCalendarEntry]'s.
   */
  Future<Iterable<Model.ContactCalendarEntry>> getCalendar(Model.Contact contact) =>
      _store.calendarMap(contact.ID, contact.receptionID)
        .then((Iterable<Map> collection) {
           return collection.map((Map map) => new Model.ContactCalendarEntry.fromMap(map));
        });

  /**
   * Return all the [Model.Contact]'s that belong to [reception].
   */
  Future<Iterable<Model.Contact>> list(Model.Reception reception) =>
      _store.listByReception(reception.ID)
        .then((Iterable<ORModel.Contact> contacts) {
          return contacts.map((ORModel.Contact contact) => new Model.Contact.fromMap(contact.asMap));
        });

  /**
   * Return all the [contact] [Model.MessageEndpoint]'s.
   */
  Future<Iterable<Model.MessageEndpoint>> endpoints(Model.Contact contact) =>
      _store.endpointsMap(contact.ID, contact.receptionID)
        .then((Iterable<Map> endpointMaps) {
          return endpointMaps.map((Map map) => new Model.MessageEndpoint.fromMap(map));
        });

  /**
   * Return all the [contact] [Model.PhoneNumber]'s.
   */
  Future<Iterable<Model.PhoneNumber>> phones(Model.Contact contact) =>
      _store.phonesMap(contact.ID, contact.receptionID)
        .then((Iterable<Map> contactMaps) {
          return contactMaps.map((Map map) => new Model.PhoneNumber.fromMap(map));
        });

  /**
   * Save [entry] to the database.
   */
  Future saveCalendarEvent (Model.ContactCalendarEntry entry) =>
      _store.calendarEventUpdate(entry);
}
