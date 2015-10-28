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
 * Client class for call-flow-control service.
 */
class CallFlowControl {
  static final String className = '${libraryName}.CallFlowControl';
  static final log = new Logger(className);

  WebService _backend = null;
  Uri _host;
  String _token = '';

  CallFlowControl(Uri this._host, String this._token, this._backend);

  /**
   * Retrives the currently active recordings
   */
  Future<Iterable<Model.ActiveRecording>> activeRecordings() {
    Uri uri = Resource.CallFlowControl.activeRecordings(this._host);
    uri = appendToken(uri, this._token);

    Iterable<Model.ActiveRecording> decodeMaps (Iterable<Map> maps) =>
        maps.map(Model.ActiveRecording.decode);

    return this._backend.get(uri)
        .then(JSON.decode)
        .then(decodeMaps);
  }

  /**
   * Retrives the currently active recordings
   */
  Future<Model.ActiveRecording> activeRecording(String channel) {
    Uri uri = Resource.CallFlowControl.activeRecording(this._host, channel);
    uri = appendToken(uri, this._token);

    return this._backend.get(uri)
        .then(JSON.decode)
        .then(Model.ActiveRecording.decode);
  }

  /**
   * Asks the server to perform a reload.
   */
  Future stateReload() {
    Uri uri = Resource.CallFlowControl.stateReload(_host);
    uri = appendToken(uri, _token);

    return _backend.post(uri, '');
  }

  /**
   * Returns a Map representation of the [Model.UserStatus] object associated
   * with [userID].
   */
  Future<Map> userStatusMap(int userID) => this._backend
      .get(appendToken(
          Resource.CallFlowControl.userStatus(this._host, userID), this._token))
      .then((String response) => JSON.decode(response));

  /**
   * Returns the [Model.UserStatus] object associated with [userID].
   */
  Future<Model.UserStatus> userStatus(int userID) => this
      .userStatusMap(userID)
      .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Returns an Iterable representation of the all the [Model.UserStatus]
   * objects currently known to the CallFlowControl server as maps.
   */
  Future<Iterable<Map>> userStatusListMaps() {
    Uri uri = Resource.CallFlowControl.userStatusList(this._host);
    uri = appendToken(uri, this._token);

    return this._backend.get(uri).then(JSON.decode);
  }

  /**
   * Returns an Iterable representation of the all the [Model.UserStatus]
   * objects currently known to the CallFlowControl server.
   */
  Future<Iterable<Model.UserStatus>> userStatusList() => this
      .userStatusListMaps()
      .then((Iterable<Map> maps) =>
          maps.map((Map map) => new Model.UserStatus.fromMap(map)));

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state idle.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Map> userStateIdleMap(int userID) => this._backend
      .post(appendToken(Resource.CallFlowControl.userState(
          this._host, userID, Model.UserState.Idle), this._token), '')
      .then((String response) => JSON.decode(response));

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state paused.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Map> userStatePausedMap(int userID) {
    Uri uri = Resource.CallFlowControl.userState(
        this._host, userID, Model.UserState.Paused);
    uri = appendToken(uri, this._token);

    return this._backend.post(uri, '').then(JSON.decode);
  }

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state logged-out.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Map> userStateLoggedOutMap(int userID) {
    Uri uri = Resource.CallFlowControl.userStateLoggedOut(this._host, userID);
    uri = appendToken(uri, this._token);

    return this._backend
        .post(uri, '')
        .then((String response) => JSON.decode(response));
  }

  /**
   * Updates the last-updted timestamp ont the [Model.UserStatus] object
   * associated with [userID].
   * The call fails if the user is logged out, or has no state on the server.
   */
  Future userStateKeepAlive(int userID) => this._backend
      .post(appendToken(
          Resource.CallFlowControl.userStateKeepAlive(this._host, userID),
          this._token), '')
      .then((String response) => JSON.decode(response));

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state logged-out.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Model.UserStatus> userStateLoggedOut(int userID) =>
      userStateLoggedOutMap(userID)
          .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state paused.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Model.UserStatus> userStatePaused(int userID) =>
      userStatePausedMap(userID)
          .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state idle.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Model.UserStatus> userStateIdle(int userID) => userStateIdleMap(userID)
      .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Returns a single call resource.
   */
  Future<Model.Call> get(String callID) {
    Uri uri = Resource.CallFlowControl.single(this._host, callID);
    uri = appendToken(uri, this._token);

    return this._backend.get(uri).then((String response) {
      Model.Call call;
      try {
        call = new Model.Call.fromMap(JSON.decode(response));
      } catch (error, stackTrace) {
        log.severe('Failed to parse \"$response\" as call object.');
        return new Future.error(error, stackTrace);
      }

      return call;
    });
  }

  /**
   * Picks up the call identified by [callID].
   */
  Future<Model.Call> pickup(String callID) => this
      .pickupMap(callID)
      .then((Map callMap) => new Model.Call.fromMap(callMap));

  /**
   * Picks up the call identified by [callID].
   * Returns a Map representation of the Call object.
   */
  Future<Map> pickupMap(String callID) {
    Uri uri = Resource.CallFlowControl.pickup(this._host, callID);
    uri = appendToken(uri, this._token);

    return this._backend.post(uri, '').then(JSON.decode);
  }

  /**
   * Originate a new call via the server.
   */
  Future<Model.Call> originate(
      String extension, int contactID, int receptionID) {
    Uri uri = Resource.CallFlowControl.originate(
        _host, extension, contactID, receptionID);
    uri = appendToken(uri, _token);

    return _backend.post(uri, '').then(JSON.decode).then(
        (Map callMap) => new Model.Call.fromMap(callMap));
  }

  /**
   * Parks the call identified by [callID].
   */
  Future<Model.Call> park(String callID) {
    Uri uri = Resource.CallFlowControl.park(this._host, callID);
    uri = appendToken(uri, this._token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map map) => new Model.Call.fromMap(map));
  }

  /**
   * Hangs up the call identified by [callID].
   */
  Future hangup(String callID) => this._backend.post(appendToken(
      Resource.CallFlowControl.hangup(this._host, callID), this._token), '');

  /**
   * Transfers the call identified by [callID] to active call [destination].
   */
  Future transfer(String callID, String destination) => this._backend.post(
      appendToken(
          Resource.CallFlowControl.transfer(this._host, callID, destination),
          this._token), '');

  /**
   * Retrives the current Call list.
   */
  Future<Iterable<Model.Call>> callList() => this
      .callListMaps()
      .then((Iterable<Map> callMaps) =>
          callMaps.map((Map map) => new Model.Call.fromMap(map)));

  /**
   * Retrives the current Call list as maps
   */
  Future<Iterable<Map>> callListMaps() {
    Uri uri = Resource.CallFlowControl.list(this._host);
    uri = appendToken(uri, this._token);

    return this._backend
        .get(uri)
        .then((String response) => (JSON.decode(response)));
  }
  /**
   * Retrives the current Peer list.
   */
  Future<Iterable<Model.Peer>> peerList() => this
      .peerListMaps()
      .then((Iterable<Map> maps) =>
          maps.map((Map map) => new Model.Peer.fromMap(map)));

  /**
   * Retrives the current Peer without doing automatic casting.
   */
  Future<Iterable<Map>> peerListMaps() {
    Uri uri = Resource.CallFlowControl.peerList(this._host);
    uri = appendToken(uri, this._token);

    return this._backend
        .get(uri)
        .then((String response) => (JSON.decode(response) as List));
  }

  /**
   * Retrives the current Channel list as a Map.
   */
  Future<Iterable<Map>> channelListMap() {
    Uri uri = Resource.CallFlowControl.channelList(this._host);
    uri = appendToken(uri, this._token);

    return this._backend
        .get(uri)
        .then((String response) => (JSON.decode(response)));
  }
}
