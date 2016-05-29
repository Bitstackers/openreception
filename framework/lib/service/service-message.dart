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

class RESTMessageStore implements Storage.Message {
  static final String className = '${libraryName}.RESTMessageStore';

  final WebService _backend;
  final Uri host;
  final String token;

  const RESTMessageStore(Uri this.host, String this.token, this._backend);

  /**
   *
   */
  Future<Model.Message> get(int mid) => this
      ._backend
      .get(_appendToken(Resource.Message.single(this.host, mid), this.token))
      .then((String response) =>
          new Model.Message.fromMap(JSON.decode(response)));

  /**
   *
   */
  Future<Iterable<Model.Message>> getByIds(Iterable<int> ids) async {
    Uri uri = Resource.Message.list(host);
    uri = _appendToken(uri, token);

    final Iterable maps = await _backend
        .post(uri, JSON.encode(ids))
        .then((String response) => JSON.decode(response));

    return maps.map(Model.Message.decode);
  }

  /**
   *
   */
  Future<Model.MessageQueueEntry> enqueue(Model.Message message) {
    Uri uri = Resource.Message.send(this.host, message.id);
    uri = _appendToken(uri, this.token);

    return this
        ._backend
        .post(uri, JSON.encode(message.asMap))
        .then(JSON.decode)
        .then((Map queueItemMap) =>
            new Model.MessageQueueEntry.fromMap(queueItemMap));
  }

  /**
   *
   */
  Future<Model.Message> create(Model.Message message, Model.User modifier) =>
      _backend
          .post(_appendToken(Resource.Message.root(this.host), this.token),
              JSON.encode(message.asMap))
          .then((String response) =>
              new Model.Message.fromMap(JSON.decode(response)));

  Future remove(int mid, Model.User modifier) {
    Uri uri = Resource.Message.single(host, mid);
    uri = _appendToken(uri, token);

    return _backend.delete(uri);
  }

  /**
   *
   */
  Future<Iterable<int>> midsOfUid(int uid) async {
    Uri uri = Resource.Message.midOfUid(host, uid);
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
    Uri uri = Resource.Message.midOfCid(host, cid);
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
    Uri uri = Resource.Message.midOfRid(host, rid);
    uri = _appendToken(uri, token);

    final ints = await _backend
        .get(uri)
        .then((String response) => JSON.decode(response));

    return ints as Iterable<int>;
  }

  /**
   *
   */
  Future<Model.Message> update(Model.Message message, Model.User modifier) =>
      _backend
          .put(
              _appendToken(
                  Resource.Message.single(this.host, message.id), this.token),
              JSON.encode(message.asMap))
          .then((String response) =>
              new Model.Message.fromMap(JSON.decode(response)));
  /**
   *
   */
  Future<Iterable<Model.Message>> list({Model.MessageFilter filter}) => this
      ._backend
      .get(_appendToken(
          Resource.Message.list(this.host, filter: filter), this.token))
      .then((String response) => (JSON.decode(response) as Iterable)
          .map((Map map) => new Model.Message.fromMap(map)));

  /**
   *
   */
  Future<Iterable<Model.Message>> listDay(DateTime day,
      {Model.MessageFilter filter}) async {
    Uri uri = Resource.Message.listDay(host, day, filter: filter);
    uri = _appendToken(uri, token);

    return _backend.get(uri).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.Message.fromMap(map)));
  }

  /**
   *
   */
  Future<Iterable<Model.Message>> listSaved({Model.MessageFilter filter}) {
    Uri uri = Resource.Message.listSaved(host, filter: filter);
    uri = _appendToken(uri, token);

    return _backend.get(uri).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.Message.fromMap(map)));
  }

  /**
   *
   */
  Future<Iterable<Model.Commit>> changes([int mid]) {
    Uri url = Resource.Message.changeList(host, mid);
    url = _appendToken(url, this.token);

    Iterable<Model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(Model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }
}
