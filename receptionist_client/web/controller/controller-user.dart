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
  final ORService.NotificationService _connectionService;
  final ORService.RESTUserStore _user;

  /**
   * Constructor.
   */
  User(this._service, this._connectionService, this._user);

  /**
   * Fetches the last known connection state of users.
   */
  Future<Iterable<ORModel.ClientConnection>> connections() =>
    _connectionService.clientConnections();

  /**
   * Fetches the connection state of a single user.
   */
  Future<ORModel.ClientConnection> connection(ORModel.User user) =>
    _connectionService.clientConnection(user.ID);

  /**
   *
   */
  Future<ORModel.User> get(int userID) => _user.get(userID);

  /**
   * Get the [Model.UserStatus] for the current user.
   */
  Future<ORModel.UserStatus> getState(ORModel.User user) =>
    _service.userStatus(user.ID);

  /**
   * Return the users list.
   */
  Future<Iterable<ORModel.User>> list() => _user.list();

  /**
   * Set the user idle.
   */
  Future<ORModel.UserStatus> setIdle(ORModel.User user) =>
    _service.userStateIdle(user.ID);

  /**
   * Set the user logged out.
   */
  Future<ORModel.UserStatus> setLoggedOut(ORModel.User user) =>
    _service.userStateLoggedOut(user.ID);

  /**
   * Set the user paused.
   */
  Future<ORModel.UserStatus> setPaused(ORModel.User user) =>
    _service.userStatePaused(user.ID);

  /**
   * Fetches a userStates of all users
   */
  Future<Iterable<ORModel.UserStatus>> stateList() =>
    _service.userStatusList();
}
