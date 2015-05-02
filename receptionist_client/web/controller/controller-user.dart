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
 * TODO (TL): Missing description of class and what it does.
 */
class User {

  final Service.Call _userStateService;

  User(this._userStateService);

  /**
   * Get the [Model.UserStatus] for the current user.
   */
  Future<Model.UserStatus> getState(Model.User user) =>
      _userStateService.userState(user.ID);

  /**
   * Set the user idle.
   *
   * TODO (TL): Proper error handling. We're not doing anything with errors from
   * the Service.Call.markUserStateIdle Future.
   */
  Future<Model.UserStatus> setIdle(Model.User user) =>
    this._userStateService.markUserStateIdle(user);

  /**
   * Set the user paused.
   *
   * TODO (TL): Proper error handling. We're not doing anyting with errors from
   * the Service.Call.markUserStatePaused Future.
   */
  Future<Model.UserStatus> setPaused(Model.User user) =>
      this._userStateService.markUserStatePaused(user);

}
