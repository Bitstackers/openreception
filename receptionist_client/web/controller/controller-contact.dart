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
   * Return all the [Model.Contact]'s that belong to [reception].
   */
  Future<Iterable<ORModel.Contact>> list(ORModel.Reception reception) =>
      _store.listByReception(reception.ID);

  /**
   * Return all the [contact] [ORModel.MessageEndpoint]'s.
   */
  Future<Iterable<ORModel.MessageEndpoint>> endpoints(ORModel.Contact contact) =>
      _store.endpoints(contact.ID, contact.receptionID);

  /**
   * Return all the [contact] [ORModel.PhoneNumber]'s.
   */
  Future<Iterable<ORModel.PhoneNumber>> phones(ORModel.Contact contact) =>
      _store.phones(contact.ID, contact.receptionID);

}