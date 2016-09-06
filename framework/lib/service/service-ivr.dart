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

/// IVR store and service client class.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building.
class RESTIvrStore implements storage.Ivr {
  final WebService _backend;

  /// The uri of the connected backend.
  final Uri host;

  /// The token used for authenticating with the backed.
  final String token;

  RESTIvrStore(Uri this.host, String this.token, this._backend);

  @override
  Future<model.IvrMenu> create(model.IvrMenu menu, [model.User user]) {
    Uri url = resource.Ivr.list(host);
    url = _appendToken(url, this.token);

    return this
        ._backend
        .post(url, JSON.encode(menu))
        .then(JSON.decode)
        .then(model.IvrMenu.decode);
  }

  Future<Iterable<String>> deploy(String menuName) async {
    Uri url = resource.Ivr.deploy(host, menuName);
    url = _appendToken(url, this.token);

    return JSON.decode(await _backend.post(url, '')) as Iterable<String>;
  }

  @override
  Future remove(String menuName, [model.User user]) {
    Uri url = resource.Ivr.single(this.host, menuName);
    url = _appendToken(url, this.token);

    return this._backend.delete(url);
  }

  @override
  Future<model.IvrMenu> get(String menuName) {
    Uri url = resource.Ivr.single(this.host, menuName);
    url = _appendToken(url, this.token);

    return this._backend.get(url).then(JSON.decode).then(model.IvrMenu.decode);
  }

  @override
  Future<Iterable<model.IvrMenu>> list() {
    Uri url = resource.Ivr.list(host);
    url = _appendToken(url, this.token);

    Iterable<model.IvrMenu> castMaps(Iterable maps) =>
        maps.map(model.IvrMenu.decode);

    return this._backend.get(url).then(JSON.decode).then(castMaps);
  }

  @override
  Future<model.IvrMenu> update(model.IvrMenu menu, [model.User user]) {
    Uri url = resource.Ivr.single(this.host, menu.name);
    url = _appendToken(url, this.token);

    return this
        ._backend
        .put(url, JSON.encode(menu))
        .then(JSON.decode)
        .then(model.IvrMenu.decode);
  }

  @override
  Future<Iterable<model.Commit>> changes([String menuName]) {
    Uri url = resource.Ivr.changeList(host, menuName);
    url = _appendToken(url, this.token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  Future<String> changelog(String menuName) {
    Uri url = resource.Ivr.changelog(host, menuName);
    url = _appendToken(url, this.token);

    return _backend.get(url);
  }
}
