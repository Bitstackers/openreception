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

class RESTMessageStore implements storage.Message {
  static final String className = '${libraryName}.RESTMessageStore';

  final WebService _backend;
  final Uri host;
  final String token;

  const RESTMessageStore(Uri this.host, String this.token, this._backend);

  /**
   *
   */
  Future<model.Message> get(int mid) => this
      ._backend
      .get(_appendToken(resource.Message.single(this.host, mid), this.token))
      .then((String response) =>
          new model.Message.fromMap(JSON.decode(response)));

  /**
   *
   */
  Future<Iterable<model.Message>> getByIds(Iterable<int> ids) async {
    Uri uri = resource.Message.list(host);
    uri = _appendToken(uri, token);

    final Iterable maps = await _backend
        .post(uri, JSON.encode(ids))
        .then((String response) => JSON.decode(response));

    return maps.map(model.Message.decode);
  }

  /**
   *
   */
  Future<model.MessageQueueEntry> enqueue(model.Message message) {
    Uri uri = resource.Message.send(this.host, message.id);
    uri = _appendToken(uri, this.token);

    return this
        ._backend
        .post(uri, JSON.encode(message.asMap))
        .then(JSON.decode)
        .then((Map queueItemMap) =>
            new model.MessageQueueEntry.fromMap(queueItemMap));
  }

  /**
   *
   */
  Future<model.Message> create(model.Message message, model.User modifier) =>
      _backend
          .post(_appendToken(resource.Message.root(this.host), this.token),
              JSON.encode(message.asMap))
          .then((String response) =>
              new model.Message.fromMap(JSON.decode(response)));

  Future remove(int mid, model.User modifier) {
    Uri uri = resource.Message.single(host, mid);
    uri = _appendToken(uri, token);

    return _backend.delete(uri);
  }

  /**
   *
   */
  Future<Iterable<int>> midsOfUid(int uid) async {
    Uri uri = resource.Message.midOfUid(host, uid);
    uri = _appendToken(uri, token);

    final ints = await _backend
        .get(uri)
        .then((String response) => JSON.decode(response));

    return ints as Iterable<int>;
  }

  /**
   *
   */
  Future<Iterable<int>> midsOfCid(int cid) async {
    Uri uri = resource.Message.midOfCid(host, cid);
    uri = _appendToken(uri, token);

    final ints = await _backend
        .get(uri)
        .then((String response) => JSON.decode(response));

    return ints as Iterable<int>;
  }

  /**
   *
   */
  Future<Iterable<int>> midsOfRid(int rid) async {
    Uri uri = resource.Message.midOfRid(host, rid);
    uri = _appendToken(uri, token);

    final ints = await _backend
        .get(uri)
        .then((String response) => JSON.decode(response));

    return ints as Iterable<int>;
  }

  /**
   *
   */
  Future<model.Message> update(model.Message message, model.User modifier) =>
      _backend
          .put(
              _appendToken(
                  resource.Message.single(this.host, message.id), this.token),
              JSON.encode(message.asMap))
          .then((String response) =>
              new model.Message.fromMap(JSON.decode(response)));
  /**
   *
   */
  Future<Iterable<model.Message>> list({model.MessageFilter filter}) => this
      ._backend
      .get(_appendToken(
          resource.Message.list(this.host, filter: filter), this.token))
      .then((String response) => (JSON.decode(response) as Iterable)
          .map((Map map) => new model.Message.fromMap(map)));

  /**
   *
   */
  Future<Iterable<model.Message>> listDay(DateTime day,
      {model.MessageFilter filter}) async {
    Uri uri = resource.Message.listDay(host, day, filter: filter);
    uri = _appendToken(uri, token);

    return _backend.get(uri).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new model.Message.fromMap(map)));
  }

  /**
   *
   */
  Future<Iterable<model.Message>> listSaved({model.MessageFilter filter}) {
    Uri uri = resource.Message.listSaved(host, filter: filter);
    uri = _appendToken(uri, token);

    return _backend.get(uri).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new model.Message.fromMap(map)));
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int mid]) {
    Uri url = resource.Message.changeList(host, mid);
    url = _appendToken(url, this.token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }
}
