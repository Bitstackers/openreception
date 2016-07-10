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
 * Client for dialplan service.
 */
class RESTDialplanStore implements storage.ReceptionDialplan {
  final WebService _backend;
  final Uri _host;
  final String _token;

  /**
   *
   */
  RESTDialplanStore(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<model.ReceptionDialplan> create(model.ReceptionDialplan rdp,
      [model.User user]) {
    Uri url = resource.ReceptionDialplan.list(_host);
    url = _appendToken(url, _token);

    return _backend
        .post(url, JSON.encode(rdp))
        .then(JSON.decode)
        .then(model.ReceptionDialplan.decode);
  }

  /**
   *
   */
  Future<model.ReceptionDialplan> get(String extension) {
    Uri url = resource.ReceptionDialplan.single(_host, extension);
    url = _appendToken(url, _token);

    return _backend
        .get(url)
        .then(JSON.decode)
        .then(model.ReceptionDialplan.decode);
  }

  /**
   *
   */
  Future<Iterable<model.ReceptionDialplan>> list() {
    Uri url = resource.ReceptionDialplan.list(_host);
    url = _appendToken(url, _token);

    Iterable<model.ReceptionDialplan> castMaps(Iterable maps) =>
        maps.map(model.ReceptionDialplan.decode);

    return _backend.get(url).then(JSON.decode).then(castMaps);
  }

  /**
   *
   */
  Future<model.ReceptionDialplan> update(model.ReceptionDialplan rdp,
      [model.User user]) {
    Uri url = resource.ReceptionDialplan.single(_host, rdp.extension);
    url = _appendToken(url, _token);

    return _backend
        .put(url, JSON.encode(rdp))
        .then(JSON.decode)
        .then(model.ReceptionDialplan.decode);
  }

  /**
   *
   */
  Future remove(String extension, [model.User user]) {
    Uri url = resource.ReceptionDialplan.single(_host, extension);
    url = _appendToken(url, _token);

    return _backend.delete(url);
  }

  /**
   *
   */
  Future<Iterable<String>> analyze(String extension) async {
    Uri url = resource.ReceptionDialplan.analyze(_host, extension);
    url = _appendToken(url, _token);

    return await _backend.post(url, '').then(JSON.decode) as Iterable<String>;
  }

  /**
   * (Re-)deploys a dialplan for a the reception identified by [receptionId]
   *
   */
  Future<Iterable<String>> deployDialplan(String extension, int rid) async {
    Uri url = resource.ReceptionDialplan.deploy(_host, extension, rid);
    url = _appendToken(url, _token);

    return JSON.decode(await _backend.post(url, '')) as Iterable<String>;
  }

  /**
   * Performs a PBX-reload of the deployed dialplan configuration.
   */
  Future reloadConfig() {
    Uri url = resource.ReceptionDialplan.reloadConfig(_host);
    url = _appendToken(url, _token);

    return _backend.post(url, '').then(JSON.decode);
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([String extension]) {
    Uri url = resource.ReceptionDialplan.changeList(_host, extension);
    url = _appendToken(url, this._token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<String> changelog(String extension) {
    Uri url = resource.ReceptionDialplan.changelog(_host, extension);
    url = _appendToken(url, this._token);

    return _backend.get(url);
  }
}
