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

/// Organization store client class.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building.
class RESTOrganizationStore implements storage.Organization {
  final WebService _backend;

  /// The uri of the connected backend.
  final Uri host;

  /// The token used for authenticating with the backed.
  final String token;

  RESTOrganizationStore(Uri this.host, String this.token, this._backend);

  @override
  Future<Iterable<model.BaseContact>> contacts(int oid) {
    Uri url = resource.Organization.contacts(this.host, oid);
    url = _appendToken(url, this.token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(model.BaseContact.decode));
  }

  @override
  Future<Iterable<model.ReceptionReference>> receptions(int oid) async {
    Uri url = resource.Organization.receptions(host, oid);
    url = _appendToken(url, this.token);

    return (JSON.decode(await _backend.get(url)) as Iterable<Map>)
        .map(model.ReceptionReference.decode);
  }

  @override
  Future<model.Organization> get(int oid) {
    Uri url = resource.Organization.single(this.host, oid);
    url = _appendToken(url, this.token);

    return this._backend.get(url).then((String response) =>
        new model.Organization.fromMap(JSON.decode(response)));
  }

  @override
  Future<model.OrganizationReference> create(
      model.Organization organization, model.User modifier) {
    Uri url = resource.Organization.root(this.host);
    url = _appendToken(url, this.token);

    String data = JSON.encode(organization);
    return this._backend.post(url, data).then((String response) =>
        model.OrganizationReference.decode(JSON.decode(response)));
  }

  @override
  Future<model.OrganizationReference> update(
      model.Organization organization, model.User modifier) {
    Uri url = resource.Organization.single(this.host, organization.id);
    url = _appendToken(url, this.token);

    String data = JSON.encode(organization);
    return this._backend.put(url, data).then((String response) =>
        model.OrganizationReference.decode(JSON.decode(response)));
  }

  @override
  Future remove(int organizationID, model.User modifier) {
    Uri url = resource.Organization.single(this.host, organizationID);
    url = _appendToken(url, this.token);

    return this._backend.delete(url).then((String response) =>
        new model.Organization.fromMap(JSON.decode(response)));
  }

  @override
  Future<Iterable<model.OrganizationReference>> list() {
    Uri url = resource.Organization.list(this.host, token: this.token);
    url = _appendToken(url, this.token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map(model.OrganizationReference.decode));
  }

  @override
  Future<Iterable<model.Commit>> changes([int oid]) {
    Uri url = resource.Organization.changeList(host, oid);
    url = _appendToken(url, this.token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  Future<String> changelog(int oid) {
    Uri url = resource.Organization.changelog(host, oid);
    url = _appendToken(url, this.token);

    return _backend.get(url);
  }
}
