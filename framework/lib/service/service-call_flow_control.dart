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
  final WebService _backend;
  final Uri _host;
  final String _token;

  CallFlowControl(this._host, this._token, this._backend);

  /**
   * Retrives the currently active recordings
   */
  Future<Iterable<Model.ActiveRecording>> activeRecordings() {
    Uri uri = Resource.CallFlowControl.activeRecordings(_host);
    uri = appendToken(uri, _token);

    Iterable<Model.ActiveRecording> decodeMaps(Iterable<Map> maps) =>
        maps.map(Model.ActiveRecording.decode);

    return _backend.get(uri).then(JSON.decode).then(decodeMaps);
  }

  /**
   * Retrives the currently active recordings
   */
  Future<Model.ActiveRecording> activeRecording(String channel) {
    Uri uri = Resource.CallFlowControl.activeRecording(_host, channel);
    uri = appendToken(uri, _token);

    return _backend
        .get(uri)
        .then(JSON.decode)
        .then(Model.ActiveRecording.decode);
  }

  /**
   * Retrives the stats of all agents.
   */
  Future<Iterable<Model.AgentStatistics>> agentStats() {
    Uri uri = Resource.CallFlowControl.agentStatistics(_host);
    uri = appendToken(uri, _token);

    Iterable<Model.AgentStatistics> decodeMaps(Iterable<Map> maps) =>
        maps.map(Model.AgentStatistics.decode);

    return _backend.get(uri).then(JSON.decode).then(decodeMaps);
  }

  /**
   * Retrives the stats of a single agent.
   */
  Future<Model.AgentStatistics> agentStat(int userId) {
    Uri uri = Resource.CallFlowControl.agentStatistic(_host, userId);
    uri = appendToken(uri, _token);

    return _backend
        .get(uri)
        .then(JSON.decode)
        .then(Model.AgentStatistics.decode);
  }

  /**
   * Retrives the current Call list.
   */
  Future<Iterable<Model.Call>> callList() {
    Uri uri = Resource.CallFlowControl.list(_host);
    uri = appendToken(uri, _token);

    return _backend.get(uri).then(JSON.decode).then((Iterable<Map> callMaps) =>
        callMaps.map((Map map) => new Model.Call.fromMap(map)));
  }

  /**
   * Retrives the current channel list as a Map.
   */
  Future<Iterable<Map>> channelListMap() {
    Uri uri = Resource.CallFlowControl.channelList(_host);
    uri = appendToken(uri, _token);

    return _backend.get(uri).then((String response) => (JSON.decode(response)));
  }

  /**
   * Retrives the a specific channel as a Map.
   */
  Future<Map> channelMap(String uuid) {
    Uri uri = Resource.CallFlowControl.channel(_host, uuid);
    uri = appendToken(uri, _token);

    return _backend.get(uri).then((String response) => (JSON.decode(response)));
  }

  /**
   * Returns a single call resource.
   */
  Future<Model.Call> get(String callID) {
    Uri uri = Resource.CallFlowControl.single(_host, callID);
    uri = appendToken(uri, _token);

    return _backend
        .get(uri)
        .then(JSON.decode)
        .then((Map map) => new Model.Call.fromMap(map));
  }

  /**
   * Hangs up the call identified by [callID].
   */
  Future hangup(String callID) {
    Uri uri = Resource.CallFlowControl.hangup(_host, callID);
    uri = appendToken(uri, _token);

    return _backend.post(uri, '');
  }

  /**
   * Originate a new call via the server.
   */
  Future<Model.Call> originate(String extension, int contactID, int receptionID,
      {String callId: ''}) {
    Uri uri = Resource.CallFlowControl
        .originate(_host, extension, contactID, receptionID, callId: callId);
    uri = appendToken(uri, _token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map callMap) => new Model.Call.fromMap(callMap));
  }

  /**
   * Parks the call identified by [callID].
   */
  Future<Model.Call> park(String callID) {
    Uri uri = Resource.CallFlowControl.park(_host, callID);
    uri = appendToken(uri, _token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map map) => new Model.Call.fromMap(map));
  }

  /**
   * Retrives the current Peer list.
   */
  Future<Iterable<Model.Peer>> peerList() {
    Uri uri = Resource.CallFlowControl.peerList(_host);
    uri = appendToken(uri, _token);

    return _backend
        .get(uri)
        .then((String response) => (JSON.decode(response) as List))
        .then((Iterable<Map> maps) =>
            maps.map((Map map) => new Model.Peer.fromMap(map)));
  }

  /**
   * Picks up the call identified by [callID].
   */
  Future<Model.Call> pickup(String callID) {
    Uri uri = Resource.CallFlowControl.pickup(_host, callID);
    uri = appendToken(uri, _token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map callMap) => new Model.Call.fromMap(callMap));
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
   * Transfers the call identified by [callID] to active call [destination].
   */
  Future transfer(String callID, String destination) {
    Uri uri = Resource.CallFlowControl.transfer(_host, callID, destination);
    uri = appendToken(uri, _token);

    return _backend.post(uri, '');
  }

  /**
   * Returns the [Model.UserStatus] object associated with [userID].
   */
  Future<Model.UserStatus> userStatus(int userID) {
    Uri uri = Resource.CallFlowControl.userStatus(_host, userID);
    uri = appendToken(uri, _token);

    return _backend.get(uri).then(JSON.decode).then(Model.UserStatus.decode);
  }

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state idle.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Model.UserStatus> userStateIdle(int userID) {
    Uri uri =
        Resource.CallFlowControl.userState(_host, userID, Model.UserState.Idle);
    uri = appendToken(uri, _token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map map) => new Model.UserStatus.fromMap(map));
  }

  /**
   * Returns an Iterable representation of the all the [Model.UserStatus]
   * objects currently known to the CallFlowControl server.
   */
  Future<Iterable<Model.UserStatus>> userStatusList() {
    Uri uri = Resource.CallFlowControl.userStatusList(_host);
    uri = appendToken(uri, _token);

    return _backend.get(uri).then(JSON.decode).then((Iterable<Map> maps) =>
        maps.map((Map map) => new Model.UserStatus.fromMap(map)));
  }

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state logged-out.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Model.UserStatus> userStateLoggedOut(int userID) {
    Uri uri = Resource.CallFlowControl
        .userState(_host, userID, Model.UserState.LoggedOut);
    uri = appendToken(uri, _token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map map) => new Model.UserStatus.fromMap(map));
  }

  /**
   * Updates the [Model.UserStatus] object associated
   * with [userID] to state paused.
   * The update is conditioned by the server and phone state and may throw
   * [ClientError] exeptions.
   */
  Future<Model.UserStatus> userStatePaused(int userID) {
    Uri uri = Resource.CallFlowControl
        .userState(_host, userID, Model.UserState.Paused);
    uri = appendToken(uri, _token);

    return _backend
        .post(uri, '')
        .then(JSON.decode)
        .then((Map map) => new Model.UserStatus.fromMap(map));
  }
}
