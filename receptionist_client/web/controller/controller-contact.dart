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
  final Notification _notification;
  final Map<int, Iterable<ORModel.ReceptionContact>> _rcCache = {};

  /**
   * Constructor.
   */
  Contact(this._store, this._notification) {
    _notification.onReceptionDataChange.listen((OREvent.ReceptionData e) {
      _rcCache.remove(e.rid);
    });

    _notification.onContactChange.listen((OREvent.ContactChange e) {
      if (e.isUpdate) {
        _rcCache.clear();
      }
    });
  }

  /**
   * Fetch the [contactId] [ORModel.Contact].
   */
  Future<ORModel.BaseContact> get(int contactId) => _store.get(contactId);

  /**
   * Return all the [Model.Contact]'s that belong to [rRef].
   */
  Future<Iterable<ORModel.ReceptionContact>> list(
      ORModel.ReceptionReference rRef) async {
    if (!_rcCache.containsKey(rRef.id)) {
      _rcCache[rRef.id] = await _store.receptionContacts(rRef.id);
    }

    return _rcCache[rRef.id];
  }
}
