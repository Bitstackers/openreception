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

part of service;

class Call {

  ORService.CallFlowControl _service = null;

  static Call _instance;

  static Call get instance {
    if (_instance == null) {
      _instance = new Call();
    }

    return _instance;
  }

  Call () {
    _service = new ORService.CallFlowControl
        (configuration.callFlowBaseUrl,
         configuration.token,
         new ORServiceHTML.Client());
  }

  Future<Iterable<Model.Call>> listCalls() =>
    _service.callListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new Model.Call.fromMap(map)));



  /**
   * Fetches a list of peers.
   */
  Future<Iterable<Model.Peer>> peerList() =>
    _service.peerListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new Model.Peer.fromMap(map)));

  /**
   * Fetches a userStates of all users
   */
  Future<Iterable<Model.UserStatus>> userStateList() =>
    _service.userStatusListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new Model.UserStatus.fromMap(map)));

  /**
   * Fetches a userState associated with userID.
   */
  Future<Model.UserStatus> userState(int userID) =>
      _service.userStatusMap(userID)
        .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Updates userState associated with userID to Idle state.
   */
  Future<Model.UserStatus> markUserStateIdle(Model.User user) =>
      _service.userStateIdleMap(user.ID)
        .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Updates userState associated with userID to Paused state.
   */
  Future<Model.UserStatus> markUserStatePaused(Model.User user) =>
      _service.userStatePausedMap(user.ID)
        .then((Map map) => new Model.UserStatus.fromMap(map));

  Future originate
    (Model.Contact contact, Model.Reception reception, String extension) =>
      _service.originate(extension, contact.ID, reception.ID);

  Future<Model.Call> pickup (Model.Call call) =>
      _service.pickupMap (call.ID).then((Map callMap) =>
          new Model.Call.fromMap(callMap));

  Future hangup (Model.Call call) =>
      _service.hangup(call.ID);

  Future park (Model.Call call) =>
      _service.park(call.ID);

  Future transfer (Model.Call source, Model.Call destination) =>
      _service.transfer(source.ID, destination.ID);
}

