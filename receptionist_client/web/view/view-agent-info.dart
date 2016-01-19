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
  final Model.AppClientState _appState;
  final Logger _log = new Logger('$libraryName.AgentInfo');
  final Controller.Notification _notification;
  final Model.UIAgentInfo _uiModel;
  final Controller.User _user;
  final Controller.Call _call;
  final Map<int, int> _userConnectionCount = {};
  final Map<int, String> _userPeer = {};
  final Map<String, bool> _peerState = {};
  final Map<int, String> _userState = {};

  /**
   * Constructor.
   */
  AgentInfo(
      Model.UIAgentInfo this._uiModel,
      Model.AppClientState this._appState,
      Controller.User this._user,
      Controller.Notification this._notification,
      Controller.Call this._call) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = Model.AgentState.UNKNOWN;
    _ui.alertState = Model.AlertState.OFF;
    _ui.portrait = 'images/face.png';

    if (_appState.currentUser.portrait.isNotEmpty) {
      _ui.portrait = _appState.currentUser.portrait;
    }

    _reloadUserState().then((_) {
      _update();
      _observers();
    });
  }

  @override Controller.Destination get _destination => null;
  @override Model.UIAgentInfo get _ui => _uiModel;

  @override void _onBlur(_) {}
  @override void _onFocus(_) {}

  /**
   * Set the users state to [AgentState.IDLE].
   */
  void _setIdle(_) {
    _user.setIdle(_appState.currentUser);
  }

  /**
   * Set the users state to [AgentState.PAUSED].
   */
  void _setPaused(_) {
    _user.setPaused(_appState.currentUser);
  }

  /**
   * Update the users state in the UI.
   */
  Future _reloadUserState() async {
    await _user.list().then((users) {
      users.forEach((user) {
        _userPeer[user.ID] = user.peer;
      });
    });

    await _user.stateList().then((status) {
      status.forEach((s) {
        _userState[s.userID] = s.state;
      });
    });

    await _call.peerList().then((peers) {
      peers.forEach((peer) {
        _peerState[peer.name] = peer.registered;
      });
    });

    await _notification.clientConnections().then((connections) {
      connections.forEach((conn) {
        _userConnectionCount[conn.userID] = conn.connectionCount;
      });
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _hotKeys.onCtrlAltEnter.listen(_setIdle);
    _hotKeys.onCtrlAltP.listen(_setPaused);

    _notification.onAgentStateChange.listen((ORModel.UserStatus userStatus) {
      _userState[userStatus.userID] = userStatus.state;
      _update();
    });

    _notification.onClientConnectionStateChange.listen((Model.ClientConnectionState state) {
      _userConnectionCount[state.userID] = state.connectionCount;
      _log.info('View.AgentInfo got '
          'Model.ClientConnectionState: ${state.asMap}');
      _update();
    });

    _notification.onPeerStateChange.listen((OREvent.PeerState state) {
      _log.info('View.AgentInfo got OREvent.PeerState: ${state.asMap}');
      _peerState[state.peer.name] = state.peer.registered;
      _update();
    });
  }

  /**
   *
   */
  void _update() {
    int active = 0;
    int passive = 0;
    bool available = false;

    /// Update counters.
    _userPeer.forEach((userId, peerId) {
      bool peerRegistered = _userPeer.containsKey(userId)
          ? _peerState.containsKey(_userPeer[userId]) ? _peerState[_userPeer[userId]] : false
          : false;

      int connectionCount =
          _userConnectionCount.containsKey(userId) ? _userConnectionCount[userId] : 0;

      available = peerRegistered && connectionCount > 0;
      if (available) {
        switch (_userState[userId]) {
          case ORModel.UserState.LoggedOut:
            _log.warning('User with id $userId is logged out while still '
                'having an active connection and peer');
            break;
          case ORModel.UserState.Paused:
          case ORModel.UserState.Unknown:
            passive++;
            break;
          default:
            active++;
            break;
        }
      }
    });

    /// Update ui for agent's user.
    switch (_userState[_appState.currentUser.ID]) {
      case ORModel.UserState.Idle:
        _ui.agentState = available ? Model.AgentState.IDLE : Model.AgentState.UNKNOWN;
        break;
      case ORModel.UserState.Paused:
        _ui.agentState = available ? Model.AgentState.PAUSED : Model.AgentState.UNKNOWN;
        break;
      case ORModel.UserState.Dialing:
      case ORModel.UserState.HandlingOffHook:
      case ORModel.UserState.HangingUp:
      case ORModel.UserState.Parking:
      case ORModel.UserState.Receiving:
      case ORModel.UserState.Speaking:
      case ORModel.UserState.Transferring:
      case ORModel.UserState.Unparking:
      case ORModel.UserState.WrappingUp:
        _ui.agentState = available ? Model.AgentState.BUSY : Model.AgentState.UNKNOWN;
        break;
      default:
        _ui.agentState = Model.AgentState.UNKNOWN;
        break;
    }
    _ui.activeCount = active;
    _ui.pausedCount = passive;
  }
}
