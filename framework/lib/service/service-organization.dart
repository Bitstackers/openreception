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
 * Client class providing REST access to an organization store.
 */
class RESTOrganizationStore implements Storage.Organization {
  static final String className = '${libraryName}.RESTOrganizationStore';

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTOrganizationStore(Uri this._host, String this._token, this._backend);

  Future<Iterable<Model.BaseContact>> contacts(int organizationID) {
    Uri url = Resource.Organization.contacts(this._host, organizationID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.BaseContact.fromMap(map)));
  }

  Future<Iterable<int>> receptions(int organizationID) {
    Uri url = Resource.Organization.receptions(_host, organizationID);
    url = _appendToken(url, this._token);

    return _backend
        .get(url)
        .then(JSON.decode)
        .then((Iterable<int> values) => values);
  }

  Future<Model.Organization> get(int organizationID) {
    Uri url = Resource.Organization.single(this._host, organizationID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Organization.fromMap(JSON.decode(response)));
  }

  Future<Model.Organization> create(Model.Organization organization) {
    Uri url = Resource.Organization.root(this._host);
    url = _appendToken(url, this._token);

    String data = JSON.encode(organization.asMap);
    return this._backend.post(url, data).then((String response) =>
        new Model.Organization.fromMap(JSON.decode(response)));
  }

  Future<Model.Organization> update(Model.Organization organization) {
    Uri url = Resource.Organization.single(this._host, organization.id);
    url = _appendToken(url, this._token);

    String data = JSON.encode(organization.asMap);
    return this._backend.put(url, data).then((String response) =>
        new Model.Organization.fromMap(JSON.decode(response)));
  }

  Future<Map<String, Map<String, String>>> receptionMap() {
    Uri url = Resource.Organization.receptionMap(this._host);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .get(url)
        .then((String response) => JSON.decode(response));
  }

  Future remove(int organizationID) {
    Uri url = Resource.Organization.single(this._host, organizationID);
    url = _appendToken(url, this._token);

    return this._backend.delete(url).then((String response) =>
        new Model.Organization.fromMap(JSON.decode(response)));
  }

  Future<Iterable<Model.Organization>> list() {
    Uri url = Resource.Organization.list(this._host, token: this._token);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.Organization.fromMap(map)));
  }
}
