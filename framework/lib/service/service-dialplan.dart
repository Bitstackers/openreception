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
 * Client for dialplan service.
 */
class RESTDialplanStore implements Storage.ReceptionDialplan {

  WebService _backend = null;
  Uri _host;
  String _token = '';

  /**
   *
   */
  RESTDialplanStore(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Model.ReceptionDialplan> create(Model.ReceptionDialplan rdp) {
    Uri url = Resource.ReceptionDialplan.list(_host);
    url = appendToken(url, this._token);

    return this
        ._backend
        .post(url, JSON.encode(rdp))
        .then(JSON.decode)
        .then(Model.ReceptionDialplan.decode);
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> get(String extension) {
    Uri url = Resource.ReceptionDialplan.single(this._host, extension);
    url = appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode).then(Model.ReceptionDialplan.decode);
  }

  /**
   *
   */
  Future<Iterable<Model.ReceptionDialplan>> list() {
    Uri url = Resource.ReceptionDialplan.list(_host);
    url = appendToken(url, this._token);

    Iterable<Model.ReceptionDialplan> castMaps(Iterable maps) =>
        maps.map(Model.ReceptionDialplan.decode);

    return this._backend.get(url).then(JSON.decode).then(castMaps);
  }

  /**
   *
   */
  Future<Model.ReceptionDialplan> update(Model.ReceptionDialplan rdp) {
    Uri url = Resource.ReceptionDialplan.single(this._host, rdp.extension);
    url = appendToken(url, this._token);

    return this
        ._backend
        .put(url, JSON.encode(rdp))
        .then(JSON.decode)
        .then(Model.ReceptionDialplan.decode);
  }

  /**
   *
   */
  Future remove(String extension) {
    Uri url = Resource.ReceptionDialplan.single(this._host, extension);
    url = appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   *
   */
  Future<Iterable<String>> analyze(String extension) {
    Uri url = Resource.ReceptionDialplan.analyze(_host, extension);
    url = appendToken(url, this._token);

    return this
        ._backend
        .post(url, '')
        .then(JSON.decode);
  }

  /**
   * (Re-)deploys a dialplan for a the reception identified by [receptionId]
   */
  Future deployDialplan(String extension, int receptionId) {
    Uri url = Resource.ReceptionDialplan.deploy(_host, extension, receptionId);
    url = appendToken(url, this._token);

    return this
        ._backend
        .post(url, '')
        .then(JSON.decode);
  }

  /**
   * Performs a PBX-reload of the deployed dialplan configuration.
   */
  Future reloadConfig() {
    Uri url = Resource.ReceptionDialplan.reloadConfig(_host);
    url = appendToken(url, this._token);

    return this
        ._backend
        .post(url, '')
        .then(JSON.decode);
  }


}
