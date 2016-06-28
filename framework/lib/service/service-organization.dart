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
 * Client class providing REST access to an organization store.
 */
class RESTOrganizationStore implements storage.Organization {
  static final String className = '${libraryName}.RESTOrganizationStore';

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTOrganizationStore(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Iterable<model.BaseContact>> contacts(int oid) {
    Uri url = resource.Organization.contacts(this._host, oid);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable).map(model.BaseContact.decode));
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> receptions(int oid) async {
    Uri url = resource.Organization.receptions(_host, oid);
    url = _appendToken(url, this._token);

    return (JSON.decode(await _backend.get(url)) as Iterable<Map>)
        .map(model.ReceptionReference.decode);
  }

  /**
   *
   */
  Future<model.Organization> get(int oid) {
    Uri url = resource.Organization.single(this._host, oid);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new model.Organization.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  Future<model.OrganizationReference> create(
      model.Organization organization, model.User modifier) {
    Uri url = resource.Organization.root(this._host);
    url = _appendToken(url, this._token);

    String data = JSON.encode(organization);
    return this._backend.post(url, data).then((String response) =>
        model.OrganizationReference.decode(JSON.decode(response)));
  }

  /**
   *
   */
  Future<model.OrganizationReference> update(
      model.Organization organization, model.User modifier) {
    Uri url = resource.Organization.single(this._host, organization.id);
    url = _appendToken(url, this._token);

    String data = JSON.encode(organization);
    return this._backend.put(url, data).then((String response) =>
        model.OrganizationReference.decode(JSON.decode(response)));
  }

  /**
   *
   */
  Future remove(int organizationID, model.User modifier) {
    Uri url = resource.Organization.single(this._host, organizationID);
    url = _appendToken(url, this._token);

    return this._backend.delete(url).then((String response) =>
        new model.Organization.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  Future<Iterable<model.OrganizationReference>> list() {
    Uri url = resource.Organization.list(this._host, token: this._token);
    url = _appendToken(url, this._token);

    return _backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map(model.OrganizationReference.decode));
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int oid]) {
    Uri url = resource.Organization.changeList(_host, oid);
    url = _appendToken(url, this._token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<String> changelog(int oid) {
    Uri url = resource.Organization.changelog(_host, oid);
    url = _appendToken(url, this._token);

    return _backend.get(url);
  }
}
