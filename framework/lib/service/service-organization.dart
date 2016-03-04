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

  Future<Iterable<Model.ContactReference>> contacts(int organizationID) {
    Uri url = Resource.Organization.contacts(this._host, organizationID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(Model.ContactReference.decode));
  }

  Future<Iterable<Model.ReceptionReference>> receptions(
      int organizationID) async {
    Uri url = Resource.Organization.receptions(_host, organizationID);
    url = _appendToken(url, this._token);

    return (await _backend.get(url).then(JSON.decode))
        .map(Model.ReceptionReference.decode);
  }

  Future<Model.Organization> get(int organizationID) {
    Uri url = Resource.Organization.single(this._host, organizationID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Organization.fromMap(JSON.decode(response)));
  }

  Future<Model.OrganizationReference> create(
      Model.Organization organization, Model.User modifier) {
    Uri url = Resource.Organization.root(this._host);
    url = _appendToken(url, this._token);

    String data = JSON.encode(organization);
    return this._backend.post(url, data).then((String response) =>
        Model.OrganizationReference.decode(JSON.decode(response)));
  }

  Future<Model.OrganizationReference> update(
      Model.Organization organization, Model.User modifier) {
    Uri url = Resource.Organization.single(this._host, organization.id);
    url = _appendToken(url, this._token);

    String data = JSON.encode(organization);
    return this._backend.put(url, data).then((String response) =>
        Model.OrganizationReference.decode(JSON.decode(response)));
  }

  Future remove(int organizationID, Model.User modifier) {
    Uri url = Resource.Organization.single(this._host, organizationID);
    url = _appendToken(url, this._token);

    return this._backend.delete(url).then((String response) =>
        new Model.Organization.fromMap(JSON.decode(response)));
  }

  Future<Iterable<Model.OrganizationReference>> list() {
    Uri url = Resource.Organization.list(this._host, token: this._token);
    url = _appendToken(url, this._token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map(Model.OrganizationReference.decode));
  }
}
