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

  static const className = '${libraryName}.Call';

  static ORService.CallFlowControl _service = null;

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
  static Future<Model.UserStatus> userState(int userID) =>
      _service.userStatusMap(userID)
        .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Updates userState associated with userID to Idle state.
   */
  static Future<Model.UserStatus> markUserStateIdle(int userID) =>
      _service.userStateIdleMap(userID)
        .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Updates userState associated with userID to Paused state.
   */
  static Future<Model.UserStatus> markUserStatePaused(int userID) =>
      _service.userStatePausedMap(userID)
        .then((Map map) => new Model.UserStatus.fromMap(map));
}

