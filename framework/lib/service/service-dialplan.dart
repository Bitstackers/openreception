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

part of orf.service;

/// Dialplan store and service client class.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building.
class RESTDialplanStore implements storage.ReceptionDialplan {
  final WebService _backend;

  /// The uri of the connected backend.
  final Uri host;

  /// The token used for authenticating with the backed.
  final String token;

  RESTDialplanStore(Uri this.host, String this.token, this._backend);

  @override
  Future<model.ReceptionDialplan> create(model.ReceptionDialplan rdp,
      [model.User user]) {
    Uri url = resource.ReceptionDialplan.list(host);
    url = _appendToken(url, token);

    return _backend.post(url, JSON.encode(rdp)).then(JSON.decode).then(
        (Map<String, dynamic> map) =>
            new model.ReceptionDialplan.fromJson(map));
  }

  @override
  Future<model.ReceptionDialplan> get(String extension) {
    Uri url = resource.ReceptionDialplan.single(host, extension);
    url = _appendToken(url, token);

    return _backend.get(url).then(JSON.decode).then(
        (Map<String, dynamic> map) =>
            new model.ReceptionDialplan.fromJson(map));
  }

  @override
  Future<Iterable<model.ReceptionDialplan>> list() {
    Uri url = resource.ReceptionDialplan.list(host);
    url = _appendToken(url, token);

    Iterable<model.ReceptionDialplan> castMaps(
            Iterable<Map<String, dynamic>> maps) =>
        maps.map((Map<String, dynamic> map) =>
            new model.ReceptionDialplan.fromJson(map));

    return _backend.get(url).then(JSON.decode).then(castMaps);
  }

  @override
  Future<model.ReceptionDialplan> update(model.ReceptionDialplan rdp,
      [model.User user]) {
    Uri url = resource.ReceptionDialplan.single(host, rdp.extension);
    url = _appendToken(url, token);

    return _backend.put(url, JSON.encode(rdp)).then(JSON.decode).then(
        (Map<String, dynamic> map) =>
            new model.ReceptionDialplan.fromJson(map));
  }

  @override
  Future<Null> remove(String extension, model.User user) async {
    Uri url = resource.ReceptionDialplan.single(host, extension);
    url = _appendToken(url, token);

    await _backend.delete(url);
  }

  Future<Iterable<String>> analyze(String extension) async {
    Uri url = resource.ReceptionDialplan.analyze(host, extension);
    url = _appendToken(url, token);

    return await _backend.post(url, '').then(JSON.decode) as Iterable<String>;
  }

  /// (Re-)deploys a dialplan for a the reception identified by [rid]
  Future<Iterable<String>> deployDialplan(String extension, int rid) async {
    Uri url = resource.ReceptionDialplan.deploy(host, extension, rid);
    url = _appendToken(url, token);

    return JSON.decode(await _backend.post(url, '')) as Iterable<String>;
  }

  /// Performs a PBX-reload of the deployed dialplan configuration.
  Future<Null> reloadConfig() async {
    Uri url = resource.ReceptionDialplan.reloadConfig(host);
    url = _appendToken(url, token);

    await _backend.post(url, '').then(JSON.decode);
  }

  @override
  Future<Iterable<model.Commit>> changes([String extension]) {
    Uri url = resource.ReceptionDialplan.changeList(host, extension);
    url = _appendToken(url, this.token);

    Iterable<model.Commit> convertMaps(Iterable<Map<String, dynamic>> maps) =>
        maps.map((Map<String, dynamic> map) => new model.Commit.fromJson(map));

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  Future<String> changelog(String extension) {
    Uri url = resource.ReceptionDialplan.changelog(host, extension);
    url = _appendToken(url, this.token);

    return _backend.get(url);
  }
}
