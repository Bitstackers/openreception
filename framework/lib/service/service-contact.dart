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

  Future<Iterable<Model.ReceptionReference>> receptions(int id) async {
    Uri url = Resource.Contact.receptions(_host, id);
    url = _appendToken(url, _token);

    return (await _backend.get(url).then(JSON.decode))
        .map(Model.ReceptionReference.decode);
  }

  Future<Iterable<Model.OrganizationReference>> organizations(int id) async {
    Uri url = Resource.Contact.organizations(_host, id);
    url = _appendToken(url, _token);

    return (await _backend.get(url).then(JSON.decode))
        .map(Model.OrganizationReference.decode);
  }

  Future<Model.BaseContact> get(int id) {
    Uri url = Resource.Contact.single(_host, id);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        new Model.BaseContact.fromMap(JSON.decode(response)));
  }

  Future<Model.ContactReference> create(
      Model.BaseContact contact, Model.User modifier) {
    Uri url = Resource.Contact.root(_host);
    url = _appendToken(url, _token);

    return _backend.post(url, JSON.encode(contact)).then((String response) =>
        Model.ContactReference.decode(JSON.decode(response)));
  }

  Future<Model.ContactReference> update(
      Model.BaseContact contact, Model.User modifier) {
    Uri url = Resource.Contact.single(_host, contact.id);
    url = _appendToken(url, _token);

    return _backend.put(url, JSON.encode(contact)).then((String response) =>
        Model.ContactReference.decode(JSON.decode(response)));
  }

  Future remove(int id, Model.User user) {
    Uri url = Resource.Contact.single(_host, id);
    url = _appendToken(url, _token);

    return _backend.delete(url);
  }

  Future<Iterable<Model.ContactReference>> list() {
    Uri url = Resource.Contact.list(_host);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(Model.ContactReference.decode));
  }

  Future<Model.ReceptionAttributes> data(int id, int rid) {
    Uri url = Resource.Contact.singleByReception(_host, id, rid);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        new Model.ReceptionAttributes.fromMap(JSON.decode(response)));
  }

  Future<Iterable<Model.ContactReference>> receptionContacts(int rid) {
    Uri url = Resource.Contact.listByReception(_host, rid);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(Model.ContactReference.decode));
  }

  Future<Model.ReceptionContactReference> addData(
      Model.ReceptionAttributes attr, Model.User user) {
    Uri url = Resource.Contact
        .singleByReception(_host, attr.contactId, attr.receptionId);
    url = _appendToken(url, _token);

    return _backend.post(url, JSON.encode(attr)).then((String response) =>
        Model.ReceptionContactReference.decode(JSON.decode(response)));
  }

  Future<Iterable<Model.ContactReference>> organizationContacts(int oid) {
    Uri url = Resource.Contact.organizationContacts(_host, oid);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(Model.ContactReference.decode));
  }

  /**
   *
   */
  Future removeData(int cid, int rid, Model.User user) {
    Uri url = Resource.Contact.singleByReception(_host, cid, rid);
    url = _appendToken(url, _token);

    return _backend.delete(url);
  }

  Future<Model.ReceptionContactReference> updateData(
      Model.ReceptionAttributes attr, Model.User user) {
    Uri url = Resource.Contact
        .singleByReception(_host, attr.contactId, attr.receptionId);
    url = _appendToken(url, _token);

    return _backend.put(url, JSON.encode(attr)).then((String response) =>
        Model.ReceptionContactReference.decode(JSON.decode(response)));
  }

  /**
   *
   */
  Future<Iterable<Model.Commit>> changes([int cid, int rid]) {
    Uri url = Resource.Contact.change(_host, cid, rid);
    url = _appendToken(url, this._token);

    Iterable<Model.UserCommit> convertMaps(Iterable<Map> maps) =>
        maps.map(Model.UserCommit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }
}
