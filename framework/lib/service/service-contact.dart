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

part of orf.service;

/// Contact store client class.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building.
class RESTContactStore implements storage.Contact {
  final WebService _backend;

  /// The uri of the connected backend.
  final Uri host;

  /// The token used for authenticating with the backed.
  final String token;

  RESTContactStore(Uri this.host, String this.token, this._backend);

  @override
  Future<Iterable<model.ReceptionReference>> receptions(int id) async {
    Uri url = resource.Contact.receptions(host, id);
    url = _appendToken(url, token);

    final Iterable<Map<String, dynamic>> maps = await _backend.get(url).then(
        (String response) =>
            JSON.decode(response) as Iterable<Map<String, dynamic>>);

    return maps.map(model.ReceptionReference.decode);
  }

  @override
  Future<Iterable<model.OrganizationReference>> organizations(int id) async {
    Uri url = resource.Contact.organizations(host, id);
    url = _appendToken(url, token);

    final Iterable<Map<String, dynamic>> maps = await _backend.get(url).then(
        (String response) =>
            JSON.decode(response) as Iterable<Map<String, dynamic>>);

    return maps.map(model.OrganizationReference.decode);
  }

  @override
  Future<model.BaseContact> get(int id) {
    Uri url = resource.Contact.single(host, id);
    url = _appendToken(url, token);

    return _backend.get(url).then((String response) =>
        new model.BaseContact.fromMap(
            JSON.decode(response) as Map<String, dynamic>));
  }

  @override
  Future<model.BaseContact> create(
      model.BaseContact contact, model.User modifier) {
    Uri url = resource.Contact.root(host);
    url = _appendToken(url, token);

    return _backend.post(url, JSON.encode(contact)).then((String response) =>
        model.BaseContact
            .decode(JSON.decode(response) as Map<String, dynamic>));
  }

  @override
  Future<Null> update(model.BaseContact contact, model.User modifier) async {
    Uri url = resource.Contact.single(host, contact.id);
    url = _appendToken(url, token);

    await _backend.put(url, JSON.encode(contact));
  }

  @override
  Future<Null> remove(int id, model.User user) async {
    Uri url = resource.Contact.single(host, id);
    url = _appendToken(url, token);

    await _backend.delete(url);
  }

  @override
  Future<Iterable<model.BaseContact>> list() {
    Uri url = resource.Contact.list(host);
    url = _appendToken(url, token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable<Map<String, dynamic>>)
            .map(model.BaseContact.decode));
  }

  @override
  Future<model.ReceptionAttributes> data(int id, int rid) {
    Uri url = resource.Contact.singleByReception(host, id, rid);
    url = _appendToken(url, token);

    return _backend.get(url).then((String response) =>
        new model.ReceptionAttributes.fromMap(
            JSON.decode(response) as Map<String, dynamic>));
  }

  @override
  Future<Iterable<model.ReceptionContact>> receptionContacts(int rid) {
    Uri url = resource.Contact.listByReception(host, rid);
    url = _appendToken(url, token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable<Map<String, dynamic>>)
            .map(model.ReceptionContact.decode));
  }

  @override
  Future<Null> addData(model.ReceptionAttributes attr, model.User user) async {
    Uri url =
        resource.Contact.singleByReception(host, attr.cid, attr.receptionId);
    url = _appendToken(url, token);

    await _backend.post(url, JSON.encode(attr));
  }

  @override
  Future<Iterable<model.BaseContact>> organizationContacts(int oid) {
    Uri url = resource.Contact.organizationContacts(host, oid);
    url = _appendToken(url, token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable<Map<String, dynamic>>)
            .map(model.BaseContact.decode));
  }

  @override
  Future<Null> removeData(int cid, int rid, model.User user) async {
    Uri url = resource.Contact.singleByReception(host, cid, rid);
    url = _appendToken(url, token);

    await _backend.delete(url);
  }

  @override
  Future<Null> updateData(
      model.ReceptionAttributes attr, model.User modifier) async {
    Uri url =
        resource.Contact.singleByReception(host, attr.cid, attr.receptionId);
    url = _appendToken(url, token);

    await _backend.put(url, JSON.encode(attr));
  }

  @override
  Future<Iterable<model.Commit>> changes([int cid, int rid]) {
    Uri url = resource.Contact.change(host, cid, rid);
    url = _appendToken(url, this.token);

    Iterable<model.Commit> convertMaps(Iterable<Map<String, dynamic>> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  Future<String> changelog(int cid) {
    Uri url = resource.Contact.changelog(host, cid);
    url = _appendToken(url, this.token);

    return _backend.get(url);
  }

  Future<String> receptionChangelog(int cid) {
    Uri url = resource.Contact.receptionChangelog(host, cid);
    url = _appendToken(url, this.token);

    return _backend.get(url);
  }
}
