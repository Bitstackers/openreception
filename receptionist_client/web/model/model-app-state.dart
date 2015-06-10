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

part of model;

enum AppState {
  LOADING,
  ERROR,
  READY
}

class AppClientState {
  ORModel.User        _currentUser = new ORModel.User.empty();
  final Bus<AppState> _stateChange = new Bus<AppState>();

  /**
   * Constructor.
   */
  AppClientState();

  /**
   * Change the application to [newState]
   */
  void changeState(AppState newState) {
    _stateChange.fire(newState);
  }

  /**
   *
   */
  ORModel.User get currentUser => _currentUser;

  /**
   *
   */
  set currentUser(ORModel.User newUser) => _currentUser = newUser;

  /**
   * Listen for [AppState] change events.
   */
  Stream<AppState> get onStateChange => this._stateChange.stream;
}
