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
 * The agent info view. This contains information about the amount of agents
 * currently logged in and how many are active/paused.
 */
class AgentInfo extends ViewWidget {
  final Logger            _log = new Logger('$libraryName.AgentInfo');
  Controller.Notification    _notification;
  final Model.UIAgentInfo _ui;
  final Controller.User   _user;

  /**
   * Constructor.
   */
  AgentInfo(Model.UIModel this._ui,
            Controller.User this._user,
            Controller.Notification this._notification) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = AgentState.UNKNOWN;
    _ui.alertState = AlertState.ON;
    _ui.portrait = 'images/face.png';

    Map userMap = Model.User.currentUser.toJson();
    if (userMap.containsKey('remote_attributes')) {
      if ((userMap['remote_attributes'] as Map).containsKey('picture')) {
        _ui.portrait = userMap['remote_attributes']['picture'];
      }
    }

    _user.getState(Model.User.currentUser).then(_updateUserState);

    _updateCounters();

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
    _user.setIdle(Model.User.currentUser).then(_updateUserState);
  }

  /**
   * Set the users state to [AgentState.PAUSED].
   *
   * TODO (TL): Deal with the fact that we currently don't handle conditions
   * where changing to paused fails.
   */
  void _setPaused(_) {
    _user.setPaused(Model.User.currentUser).then(_updateUserState);
  }

  /**
   * Update the users state in the UI.
   */
  void _updateUserState(Model.UserStatus userStatus) {
    switch(userStatus.state) {
      case 'busy':
        _ui.agentState = AgentState.BUSY;
        break;
      case 'idle':
        _ui.agentState = AgentState.IDLE;
        break;
      case 'paused':
        _ui.agentState = AgentState.PAUSED;
        break;
      default:
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

    _notification.onAgentStateChange.listen((Model.UserStatus userStatus) {
      _updateUserState(userStatus);
      _updateCounters();
    });

    _notification.onClientConnectionStateChange.listen((Model.ClientConnectionState state) {
      print('View.AgentInfo got Model.ClientConnectionState: ${state.asMap}');
    });
  }

  /**
   * Update active/paused counters.
   *
   * We do this by fetching a list of all users state, and count each of their
   * state.
   */
  void _updateCounters() {
    _user.userStateList().then((Iterable<Model.UserStatus> userStates) {
      _ui.activeCount = userStates.where((Model.UserStatus user)
        => user.state == ORModel.UserState.Idle).length;

      _ui.pausedCount = userStates.where((Model.UserStatus user)
      => user.state == ORModel.UserState.Paused).length;
    })
    .catchError((error) => _log.warning('${error.toString()}'));
  }
}
