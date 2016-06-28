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
class RESTIvrStore implements storage.Ivr {
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
  Future<model.IvrMenu> create(model.IvrMenu menu, [model.User user]) {
    Uri url = resource.Ivr.list(_host);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .post(url, JSON.encode(menu))
        .then(JSON.decode)
        .then(model.IvrMenu.decode);
  }

  /**
   *
   */
  Future<Iterable<String>> deploy(String menuName) async {
    Uri url = resource.Ivr.deploy(_host, menuName);
    url = _appendToken(url, this._token);

    return JSON.decode(await _backend.post(url, '')) as Iterable<String>;
  }

  /**
   *
   */
  Future remove(String menuName, [model.User user]) {
    Uri url = resource.Ivr.single(this._host, menuName);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
  *
  */
  Future<model.IvrMenu> get(String menuName) {
    Uri url = resource.Ivr.single(this._host, menuName);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode).then(model.IvrMenu.decode);
  }

  /**
   *
   */
  Future<Iterable<model.IvrMenu>> list() {
    Uri url = resource.Ivr.list(_host);
    url = _appendToken(url, this._token);

    Iterable<model.IvrMenu> castMaps(Iterable maps) =>
        maps.map(model.IvrMenu.decode);

    return this._backend.get(url).then(JSON.decode).then(castMaps);
  }

  /**
   *
   */
  Future<model.IvrMenu> update(model.IvrMenu menu, [model.User user]) {
    Uri url = resource.Ivr.single(this._host, menu.name);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .put(url, JSON.encode(menu))
        .then(JSON.decode)
        .then(model.IvrMenu.decode);
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([String menuName]) {
    Uri url = resource.Ivr.changeList(_host, menuName);
    url = _appendToken(url, this._token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<String> changelog(String menuName) {
    Uri url = resource.Ivr.changelog(_host, menuName);
    url = _appendToken(url, this._token);

    return _backend.get(url);
  }
}
