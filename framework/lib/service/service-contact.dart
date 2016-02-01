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

part of openreception.service;

/**
 * Client for contact service.
 */
class RESTContactStore implements Storage.Contact {
  final WebService _backend;
  final Uri _host;
  final String _token;

  RESTContactStore(Uri this._host, String this._token, this._backend);

  Future<Iterable<int>> receptions(int contactID) async {
    Uri url = Resource.Contact.receptions(_host, contactID);
    url = _appendToken(url, _token);

    return await _backend.get(url).then(JSON.decode) as Iterable<int>;
  }

  Future<Iterable<int>> organizations(int contactID) async {
    Uri url = Resource.Contact.organizations(_host, contactID);
    url = _appendToken(url, _token);

    return await _backend.get(url).then(JSON.decode) as Iterable<int>;
  }

  Future<Iterable<Model.Contact>> managementServerList(int receptionID) {
    Uri url = Resource.Contact.managementServerList(_host, receptionID);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response)['receptionContacts'] as Iterable)
            .map((Map map) => new Model.Contact.fromMap(map)));
  }

  Future<Model.BaseContact> get(int contactID) {
    Uri url = Resource.Contact.single(_host, contactID);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        new Model.BaseContact.fromMap(JSON.decode(response)));
  }

  Future<Model.BaseContact> create(Model.BaseContact contact) {
    Uri url = Resource.Contact.root(_host);
    url = _appendToken(url, _token);

    String data = JSON.encode(contact.asMap);
    return _backend.post(url, data).then((String response) =>
        new Model.BaseContact.fromMap(JSON.decode(response)));
  }

  Future<Model.BaseContact> update(Model.BaseContact contact) {
    Uri url = Resource.Contact.single(_host, contact.id);
    url = _appendToken(url, _token);

    String data = JSON.encode(contact.asMap);
    return _backend.put(url, data).then((String response) =>
        new Model.BaseContact.fromMap(JSON.decode(response)));
  }

  Future remove(int contactId) {
    Uri url = Resource.Contact.single(_host, contactId);
    url = _appendToken(url, _token);

    return _backend.delete(url);
  }

  Future<Iterable<Model.BaseContact>> list() {
    Uri url = Resource.Contact.list(_host);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) => (JSON.decode(response)
        as Iterable).map((Map map) => new Model.BaseContact.fromMap(map)));
  }

  Future<Model.Contact> getByReception(int contactID, int receptionID) {
    Uri url = Resource.Contact.singleByReception(_host, contactID, receptionID);
    url = _appendToken(url, _token);

    return _backend.get(url).then(
        (String response) => new Model.Contact.fromMap(JSON.decode(response)));
  }

  Future<Iterable<Model.Contact>> listByReception(int receptionID,
      {Model.ContactFilter filter}) {
    Uri url = Resource.Contact.listByReception(_host, receptionID);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) => (JSON.decode(response)
        as Iterable).map((Map map) => new Model.Contact.fromMap(map)));
  }

  Future<Iterable<Model.MessageEndpoint>> endpoints(
      int contactID, int receptionID) {
    Uri url = Resource.Contact.endpoints(_host, contactID, receptionID);
    url = _appendToken(url, _token);

    return _backend.get(url).then(JSON.decode).then((Iterable<Map> maps) =>
        maps.map((Map map) => new Model.MessageEndpoint.fromMap(map)));
  }

  Future<Iterable<Model.PhoneNumber>> phones(int contactID, int receptionID) {
    Uri url = Resource.Contact.phones(_host, contactID, receptionID);
    url = _appendToken(url, _token);

    return _backend.get(url).then(JSON.decode).then((Iterable<Map> maps) =>
        maps.map((Map map) => new Model.PhoneNumber.fromMap(map)));
  }

  Future<Iterable<Model.BaseContact>> colleagues(int contactId) {
    Uri url = Resource.Contact.colleagues(_host, contactId);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) => (JSON.decode(response)
        as Iterable).map((Map map) => new Model.BaseContact.fromMap(map)));
  }

  Future<Model.Contact> addToReception(Model.Contact contact, int receptionID) {
    Uri url =
        Resource.Contact.singleByReception(_host, contact.ID, receptionID);
    url = _appendToken(url, _token);

    return _backend.post(url, JSON.encode(contact)).then(
        (String response) => new Model.Contact.fromMap(JSON.decode(response)));
  }

  Future<Iterable<Model.BaseContact>> organizationContacts(int organizationId) {
    Uri url = Resource.Contact.organizationContacts(_host, organizationId);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) => (JSON.decode(response)
        as Iterable).map((Map map) => new Model.BaseContact.fromMap(map)));
  }

  Future removeFromReception(int contactId, int receptionID) {
    Uri url = Resource.Contact.singleByReception(_host, contactId, receptionID);
    url = _appendToken(url, _token);

    return _backend.delete(url);
  }

  Future<Model.Contact> updateInReception(Model.Contact contact) {
    Uri url = Resource.Contact
        .singleByReception(_host, contact.ID, contact.receptionID);
    url = _appendToken(url, _token);

    return _backend.put(url, JSON.encode(contact)).then(
        (String response) => new Model.Contact.fromMap(JSON.decode(response)));
  }
}
