/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of controller;

/**
 * Methods for getting and setting user state.
 */
class User {

  final ORService.CallFlowControl _service;

  /**
   * Constructor.
   */
  User(this._service);

  /**
   * Get the [Model.UserStatus] for the current user.
   */
  Future<Model.UserStatus> getState(Model.User user) =>
    this._service.userStatusMap(user.ID)
      .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Set the user idle.
   *
   * TODO (TL): Proper error handling. We're not doing anything with errors from
   * the Service.Call.markUserStateIdle Future.
   */
  Future<Model.UserStatus> setIdle(Model.User user) =>
    this._service.userStateIdleMap(user.ID)
      .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Set the user logged out.
   *
   * TODO (TL): Proper error handling. We're not doing anything with errors from
   * the Service.Call.markUserStateIdle Future.
   */
  Future<Model.UserStatus> setLoggedOut(Model.User user) =>
    this._service.userStateLoggedOut(user.ID)
      .then((Model.UserStatus status) => status);

  /**
   * Set the user paused.
   *
   * TODO (TL): Proper error handling. We're not doing anyting with errors from
   * the Service.Call.markUserStatePaused Future.
   */
  Future<Model.UserStatus> setPaused(Model.User user) =>
    this._service.userStatePausedMap(user.ID)
      .then((Map map) => new Model.UserStatus.fromMap(map));

  /**
   * Fetches a userStates of all users
   */
  Future<Iterable<Model.UserStatus>> userStateList() =>
    _service.userStatusListMaps()
      .then((Iterable<Map> maps) =>
        maps.map((Map map) =>
          new Model.UserStatus.fromMap(map)));
}
