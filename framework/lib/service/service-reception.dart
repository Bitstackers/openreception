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

class RESTReceptionStore implements Storage.Reception {
  static final String className = '${libraryName}.RESTReceptionStore';

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTReceptionStore(Uri this._host, String this._token, this._backend);

  /**
   * Returns a reception as a pure map.
   */
  Future<Model.ReceptionReference> create(
      Model.Reception reception, Model.User modifier) {
    Uri url = Resource.Reception.root(this._host);
    url = _appendToken(url, this._token);

    return _backend
        .post(url, JSON.encode(reception))
        .then(JSON.decode)
        .then(Model.ReceptionReference.decode);
  }

  /**
   *
   */
  Future<Model.Reception> get(int receptionID) {
    Uri url = Resource.Reception.single(this._host, receptionID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Reception.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  Future<String> extensionOf(int receptionId) {
    Uri url = Resource.Reception.extensionOf(this._host, receptionId);
    url = _appendToken(url, this._token);

    return this._backend.get(url);
  }

  /**
   *
   */
  Future<Model.Reception> getByExtension(String extension) {
    Uri url = Resource.Reception.byExtension(this._host, extension);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.Reception.fromMap(JSON.decode(response)));
  }

  /**
   * Returns a reception list.
   */
  Future<Iterable<Model.ReceptionReference>> list() {
    Uri url = Resource.Reception.list(this._host);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => Model.ReceptionReference.decode(map)));
  }

  /**
   *
   */
  Future remove(int rid, Model.User modifier) async {
    Uri url = Resource.Reception.single(this._host, rid);
    url = _appendToken(url, this._token);

    await _backend.delete(url);
  }

  /**
   *
   */
  Future<Model.ReceptionReference> update(
      Model.Reception reception, Model.User modifier) {
    Uri url = Resource.Reception.single(this._host, reception.id);
    url = _appendToken(url, this._token);

    String data = JSON.encode(reception);

    return this._backend.put(url, data).then((String response) =>
        Model.ReceptionReference.decode(JSON.decode(response)));
  }

  /**
   *
   */
  Future<Iterable<Model.Commit>> changes([int rid]) {
    Uri url = Resource.Reception.changeList(_host, rid);
    url = _appendToken(url, this._token);

    Iterable<Model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(Model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }
}
