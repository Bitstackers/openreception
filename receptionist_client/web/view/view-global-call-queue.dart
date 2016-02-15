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
 * Show the global call queue and registers keyboard shortcuts for call handling.
 *
 * This reloads the call queue list at a fixed refresh rate of [_refreshRate].
 */
class GlobalCallQueue extends ViewWidget {
  final Model.AppClientState _appState;
  final Controller.Call _callController;
  DateTime _lastPling = new DateTime.now();
  final Controller.Destination _myDestination;
  final Controller.Notification _notification;
  final Controller.Sound _sound;
  final Model.UIGlobalCallQueue _uiModel;
  ORModel.UserStatus _userState;

  /**
   * Constructor.
   */
  GlobalCallQueue(
      Model.UIGlobalCallQueue this._uiModel,
      Model.AppClientState this._appState,
      Controller.Destination this._myDestination,
      Controller.Notification this._notification,
      Controller.Call this._callController,
      Controller.Sound this._sound,
      ORModel.UserStatus this._userState) {
    _loadCallList();

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIGlobalCallQueue get _ui => _uiModel;

  @override void _onBlur(Controller.Destination _) {}
  @override void _onFocus(Controller.Destination _) {}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Add, remove, update the queue list, depending on the [call] state.
   */
  void _handleCallStateChanges(OREvent.CallEvent event) {
    final ORModel.Call call = event.call;

    if (event is OREvent.CallOffer) {
      _ui.appendCall(call);
      _pling();
    } else if (event is OREvent.CallHangup || call.assignedTo != ORModel.User.noID) {
      _ui.removeCall(call);
    } else if (call.inbound) {
      _ui.updateCall(call);
    }
  }

  /**
   * Load the list of calls not currently assigned to anybody.
   */
  void _loadCallList() {
    bool unassigned(ORModel.Call call) => call.assignedTo == ORModel.User.noID;

    _callController.listCalls().then((Iterable<ORModel.Call> calls) {
      _ui.calls = calls.where(unassigned).toList(growable: false);
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.onClick.listen((MouseEvent _) => _activateMe());

    _notification.onAnyCallStateChange.listen(_handleCallStateChanges);

    /**
     * Change the user/agent state for the currently logged in user.
     */
    _notification.onAgentStateChange.listen((ORModel.UserStatus userStatus) {
      if (userStatus.userID == _appState.currentUser.id) {
        _userState = userStatus;
      }
    });

    /**
     * Check each second to see if it is time to pling!
     */
    new Timer.periodic(new Duration(seconds: 1), (_) {
      _pling();
    });
  }

  /**
   * Pling - if:
   *  there are calls in the queue AND
   *  appState.activeCall is NOT noCall AND
   *  the agent state is idle or unknown AND
   *  >= 5 seconds have passed since the previous ping.
   */
  void _pling() {
    final DateTime now = new DateTime.now();
    final Duration difference = now.difference(_lastPling);
    if (difference.inSeconds >= 5 &&
        _ui.hasCalls &&
        _appState.activeCall == ORModel.Call.noCall &&
        !_userState.paused) {
      _lastPling = now;
      _sound.pling();
    }
  }
}
