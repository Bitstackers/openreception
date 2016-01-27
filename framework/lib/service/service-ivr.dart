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
class RESTIvrStore implements Storage.Ivr {
  WebService _backend = null;
  Uri _host;
  String _token = '';

  /**
   *
   */
  RESTIvrStore(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Model.IvrMenu> create(Model.IvrMenu menu) {
    Uri url = Resource.Ivr.list(_host);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .post(url, JSON.encode(menu))
        .then(JSON.decode)
        .then(Model.IvrMenu.decode);
  }

  /**
   *
   */
  Future<Model.IvrMenu> deploy(String menuName) {
    Uri url = Resource.Ivr.deploy(_host, menuName);
    url = _appendToken(url, this._token);

    return _backend.post(url, '')
        .then(JSON.decode)
        .then(Model.IvrMenu.decode);
  }

  /**
   *
   */
  Future remove(String menuName) {
    Uri url = Resource.Ivr.single(this._host, menuName);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
  *
  */
  Future<Model.IvrMenu> get(String menuName) {
    Uri url = Resource.Ivr.single(this._host, menuName);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode).then(Model.IvrMenu.decode);
  }

  /**
   *
   */
  Future<Iterable<Model.IvrMenu>> list() {
    Uri url = Resource.Ivr.list(_host);
    url = _appendToken(url, this._token);

    Iterable<Model.IvrMenu> castMaps(Iterable maps) =>
        maps.map(Model.IvrMenu.decode);

    return this._backend.get(url).then(JSON.decode).then(castMaps);
  }

  /**
   *
   */
  Future<Model.IvrMenu> update(Model.IvrMenu menu) {
    Uri url = Resource.Ivr.single(this._host, menu.name);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .put(url, JSON.encode(menu))
        .then(JSON.decode)
        .then(Model.IvrMenu.decode);
  }
}
