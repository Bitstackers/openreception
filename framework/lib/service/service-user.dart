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
 * Client for user service.
 */
class RESTUserStore implements storage.User {
  static final String className = '${libraryName}.RESTUserStore';
  static final Logger log = new Logger(className);

  WebService _backend = null;
  Uri _host;
  String _token = '';

  /**
   *
   */
  RESTUserStore(Uri this._host, String this._token, this._backend);

  /**
   *
   */
  Future<Iterable<model.UserReference>> list() {
    Uri url = resource.User.list(_host);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .get(url)
        .then((String reponse) => JSON.decode(reponse))
        .then((Iterable userMaps) => userMaps.map(model.UserReference.decode));
  }

  /**
   *
   */
  Future<model.User> get(int userId) {
    Uri url = resource.User.single(_host, userId);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .get(url)
        .then((String reponse) => JSON.decode(reponse))
        .then(((Map userMap) => new model.User.fromMap(userMap)));
  }

  /**
   *
   */
  Future<model.User> getByIdentity(String identity) {
    Uri url = resource.User.singleByIdentity(_host, identity);
    url = _appendToken(url, this._token);

    return _backend
        .get(url)
        .then(JSON.decode)
        .then(((Map userMap) => new model.User.fromMap(userMap)));
  }

  /**
   *
   */
  Future<Iterable<String>> groups() {
    Uri url = resource.User.group(_host);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .get(url)
        .then((String reponse) => JSON.decode(reponse) as Iterable<String>);
  }

  /**
   *
   */
  Future<model.UserReference> create(model.User user, model.User creator) {
    Uri url = resource.User.root(_host);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .post(url, JSON.encode(user))
        .then((String reponse) => JSON.decode(reponse))
        .then((model.UserReference.decode));
  }

  /**
   *
   */
  Future<model.UserReference> update(model.User user, model.User creator) {
    Uri url = resource.User.single(_host, user.id);
    url = _appendToken(url, this._token);

    return this
        ._backend
        .put(url, JSON.encode(user))
        .then((String reponse) => JSON.decode(reponse))
        .then((model.UserReference.decode));
  }

  /**
   *
   */
  Future remove(int userId, model.User creator) {
    Uri url = resource.User.single(_host, userId);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  /**
   * Returns the [model.UserStatus] object associated with [userID].
   */
  Future<model.UserStatus> userStatus(int userID) {
    Uri uri = resource.User.userState(_host, userID);
    uri = _appendToken(uri, _token);

    return _backend.get(uri).then(JSON.decode).then(model.UserStatus.decode);
  }

  /**
   * Updates the [model.UserStatus] object associated
   * with [userID] to state ready.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<model.UserStatus> userStateReady(int userId) {
    Uri uri = resource.User.setUserState(_host, userId, model.UserState.ready);
    uri = _appendToken(uri, _token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map map) => new model.UserStatus.fromMap(map));
  }

  /**
   * Returns an Iterable representation of the all the [model.UserStatus]
   * objects currently known to the CallFlowControl server.
   */
  Future<Iterable<model.UserStatus>> userStatusList() {
    Uri uri = resource.User.userStateAll(_host);
    uri = _appendToken(uri, _token);

    return _backend.get(uri).then(JSON.decode).then((Iterable<Map> maps) =>
        maps.map((Map map) => new model.UserStatus.fromMap(map)));
  }

  /**
   * Updates the [model.UserStatus] object associated
   * with [userID] to state paused.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<model.UserStatus> userStatePaused(int userId) {
    Uri uri = resource.User.setUserState(_host, userId, model.UserState.paused);
    uri = _appendToken(uri, _token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map map) => new model.UserStatus.fromMap(map));
  }

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int uid]) {
    Uri url = resource.User.change(_host, uid);
    url = _appendToken(url, this._token);

    Iterable<model.Commit> convertMaps(Iterable<Map> maps) =>
        maps.map(model.Commit.decode);

    return this._backend.get(url).then(JSON.decode).then(convertMaps);
  }

  /**
   *
   */
  Future<String> changelog(int uid) {
    Uri url = resource.User.changelog(_host, uid);
    url = _appendToken(url, this._token);

    return _backend.get(url);
  }
}
