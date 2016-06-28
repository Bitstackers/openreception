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

part of openreception.framework.service;

/**
 * Client for contact service.
 */
class RESTContactStore implements storage.Contact {
  final WebService _backend;
  final Uri _host;
  final String _token;

  RESTContactStore(Uri this._host, String this._token, this._backend);

  Future<Iterable<model.ReceptionReference>> receptions(int id) async {
    Uri url = resource.Contact.receptions(_host, id);
    url = _appendToken(url, _token);

    final Iterable<Map> maps = await _backend
        .get(url)
        .then((String response) => JSON.decode(response) as Iterable<Map>);

    return maps.map(model.ReceptionReference.decode);
  }

  Future<Iterable<model.OrganizationReference>> organizations(int id) async {
    Uri url = resource.Contact.organizations(_host, id);
    url = _appendToken(url, _token);

    final Iterable<Map> maps = await _backend
        .get(url)
        .then((String response) => JSON.decode(response) as Iterable<Map>);

    return maps.map(model.OrganizationReference.decode);
  }

  Future<model.BaseContact> get(int id) {
    Uri url = resource.Contact.single(_host, id);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        new model.BaseContact.fromMap(JSON.decode(response)));
  }

  Future<model.BaseContact> create(
      model.BaseContact contact, model.User modifier) {
    Uri url = resource.Contact.root(_host);
    url = _appendToken(url, _token);

    return _backend.post(url, JSON.encode(contact)).then(
        (String response) => model.BaseContact.decode(JSON.decode(response)));
  }

  Future<model.BaseContact> update(
      model.BaseContact contact, model.User modifier) {
    Uri url = resource.Contact.single(_host, contact.id);
    url = _appendToken(url, _token);

    return _backend.put(url, JSON.encode(contact)).then(
        (String response) => model.BaseContact.decode(JSON.decode(response)));
  }

  Future remove(int id, model.User user) {
    Uri url = resource.Contact.single(_host, id);
    url = _appendToken(url, _token);

    return _backend.delete(url);
  }

  Future<Iterable<model.BaseContact>> list() {
    Uri url = resource.Contact.list(_host);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(model.BaseContact.decode));
  }

  Future<model.ReceptionAttributes> data(int id, int rid) {
    Uri url = resource.Contact.singleByReception(_host, id, rid);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        new model.ReceptionAttributes.fromMap(JSON.decode(response)));
  }

  Future<Iterable<model.ReceptionContact>> receptionContacts(int rid) {
    Uri url = resource.Contact.listByReception(_host, rid);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(model.ReceptionContact.decode));
  }

  Future addData(model.ReceptionAttributes attr, model.User user) {
    Uri url =
        resource.Contact.singleByReception(_host, attr.cid, attr.receptionId);
    url = _appendToken(url, _token);

    return _backend.post(url, JSON.encode(attr));
  }

  Future<Iterable<model.BaseContact>> organizationContacts(int oid) {
    Uri url = resource.Contact.organizationContacts(_host, oid);
    url = _appendToken(url, _token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(model.BaseContact.decode));
  }

  /**
   *
   */
  Future removeData(int cid, int rid, model.User user) {
    Uri url = resource.Contact.singleByReception(_host, cid, rid);
    url = _appendToken(url, _token);

    return _backend.delete(url);
  }

  Future updateData(model.ReceptionAttributes attr, model.User modifier) {
    Uri url =
        resource.Contact.singleByReception(_host, attr.cid, attr.receptionId);
    url = _appendToken(url, _token);

    return _backend.put(url, JSON.encode(attr));
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int cid, int rid]) {
    Uri url = resource.Contact.change(_host, cid, rid);
    url = _appendToken(url, this._token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<String> changelog(int cid) {
    Uri url = resource.Contact.changelog(_host, cid);
    url = _appendToken(url, this._token);

    return _backend.get(url);
  }

  /**
   *
   */
  Future<String> receptionChangelog(int cid) {
    Uri url = resource.Contact.receptionChangelog(_host, cid);
    url = _appendToken(url, this._token);

    return _backend.get(url);
  }
}
