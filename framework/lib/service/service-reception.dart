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

/// Reception store client class.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building.
class RESTReceptionStore implements storage.Reception {
  final WebService _backend;

  /// The uri of the connected backend.
  final Uri host;

  /// The token used for authenticating with the backed.
  final String token;

  RESTReceptionStore(Uri this.host, String this.token, this._backend);

  /**
   * Returns a reception as a pure map.
   */
  Future<model.ReceptionReference> create(
      model.Reception reception, model.User modifier) {
    Uri url = resource.Reception.root(this.host);
    url = _appendToken(url, this.token);

    return _backend
        .post(url, JSON.encode(reception))
        .then(JSON.decode)
        .then(model.ReceptionReference.decode);
  }

  /**
   *
   */
  Future<model.Reception> get(int receptionID) {
    Uri url = resource.Reception.single(this.host, receptionID);
    url = _appendToken(url, this.token);

    return this._backend.get(url).then((String response) =>
        new model.Reception.fromMap(JSON.decode(response)));
  }

  /**
   *
   */
  Future<String> extensionOf(int receptionId) {
    Uri url = resource.Reception.extensionOf(this.host, receptionId);
    url = _appendToken(url, this.token);

    return this._backend.get(url);
  }

  /**
   *
   */
  Future<model.Reception> getByExtension(String extension) {
    Uri url = resource.Reception.byExtension(this.host, extension);
    url = _appendToken(url, this.token);

    return this._backend.get(url).then((String response) =>
        new model.Reception.fromMap(JSON.decode(response)));
  }

  /**
   * Returns a reception list.
   */
  Future<Iterable<model.ReceptionReference>> list() {
    Uri url = resource.Reception.list(this.host);
    url = _appendToken(url, this.token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => model.ReceptionReference.decode(map)));
  }

  /**
   *
   */
  Future remove(int rid, model.User modifier) async {
    Uri url = resource.Reception.single(this.host, rid);
    url = _appendToken(url, this.token);

    await _backend.delete(url);
  }

  /**
   *
   */
  Future<model.ReceptionReference> update(
      model.Reception reception, model.User modifier) {
    Uri url = resource.Reception.single(this.host, reception.id);
    url = _appendToken(url, this.token);

    String data = JSON.encode(reception);

    return this._backend.put(url, data).then((String response) =>
        model.ReceptionReference.decode(JSON.decode(response)));
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int rid]) {
    Uri url = resource.Reception.changeList(host, rid);
    url = _appendToken(url, this.token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<String> changelog(int rid) {
    Uri url = resource.Reception.changelog(host, rid);
    url = _appendToken(url, this.token);

    return _backend.get(url);
  }
}
