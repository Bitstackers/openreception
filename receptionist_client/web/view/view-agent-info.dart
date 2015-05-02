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

part of view;

/**
 * TODO (TL): Comment
 */
class AgentInfo extends ViewWidget {
  final Logger            _log = new Logger('$libraryName.AgentInfo');
  final Model.UIAgentInfo _ui;
  final Controller.User   _user;

  /**
   * Constructor.
   * Add Iterable<UserStatus> as parameter for extraction of global user state.
   */
  AgentInfo(Model.UIModel this._ui, Controller.User this._user) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = AgentState.UNKNOWN;
    _ui.alertState = AlertState.ON;
    _ui.portrait = 'images/face.png';

    /// TODO (TL): Add a portrait getter to Model.User.
    _ui.portrait = Model.User.currentUser.toJson()['remote_attributes']['picture'];

    _user.getState(Model.User.currentUser).then(_updateUserState);

    _observers();
  }

  @override Controller.Destination get myDestination => null;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Set the users state to [AgentState.IDLE].
   *
   * TODO (TL): Deal with the fact that we currently don't handle conditions
   * where changing to idle fails.
   */
  void _setIdle(_) {
    /// TODO (TL): Only call this if state != idle
    _user.setIdle(Model.User.currentUser).then(_updateUserState);
  }

  /**
   * Set the users state to [AgentState.PAUSED].
   *
   * TODO (TL): Deal with the fact that we currently don't handle conditions
   * where changing to paused fails.
   */
  void _setPaused(_) {
    /// TODO (TL): Only call this if state is != paused
    _user.setPaused(Model.User.currentUser).then(_updateUserState);
  }

  /**
   * Update the users state in the UI.
   */
  void _updateUserState(Model.UserStatus userStatus) {
    /// TODO (TL): This entire switch goes away when Model.UserStatus.state
    /// return the AgentState enum. Currently it is a String.
    switch(userStatus.state) {
      case 'busy':
        _ui.agentState = AgentState.BUSY;
        break;
      case 'idle':
        /// TODO (TL): Idle graphic is currently the same as BUSY. Fix!
        _ui.agentState = AgentState.IDLE;
        break;
      case 'paused':
        _ui.agentState = AgentState.PAUSED;
        break;
      default:
        /// TODO (TL): Unknown graphic is currently the same as IDLE. Fix!
        _ui.agentState = AgentState.UNKNOWN;
        break;
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _hotKeys.onCtrlAltEnter.listen(_setIdle);
    _hotKeys.onCtrlAltP.listen(_setPaused);

    /// TODO (TL): Add relevant listeners
    ///   _ui.activeCount = active count
    ///   _ui.alertState = alert state
    ///   _ui.pausedCount = paused count
    ///   Listen on Notification socket UserStatus events and update UI
    ///   accordingly
    ///
  }
}
