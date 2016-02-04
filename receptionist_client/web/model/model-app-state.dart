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

enum AppState { loading, error, ready }

class AppClientState {
  ORModel.Call _activeCall = ORModel.Call.noCall;
  final Bus<ORModel.Call> _activeCallChangeBus = new Bus<ORModel.Call>();
  ORModel.User _currentUser = new ORModel.User.empty();
  final Logger _log = new Logger('${libraryName}.AppClientState');
  final Controller.Notification _notification;
  final Bus<AppState> _stateChange = new Bus<AppState>();

  /**
   * Constructor.
   */
  AppClientState(Controller.Notification this._notification) {
    _observers();
  }

  /**
   * Fires an ORModel.Call on pickup and hangup.
   */
  Stream<ORModel.Call> get activeCallChanged => _activeCallChangeBus.stream;

  /**
   * Return the currently active call.
   */
  ORModel.Call get activeCall => _activeCall;

  /**
   * Set the currently active call. A hangup is when [newCall] is [ORModel.Call.noCall].
   */
  set activeCall(ORModel.Call newCall) {
    ORModel.Call previousCall = _activeCall;

    _activeCall = newCall;

    if (_activeCall.ID != previousCall.ID) {
      _activeCallChangeBus.fire(_activeCall);
      _log.finest(
          'Changing active call to ${_activeCall == ORModel.Call.noCall ? 'noCall' : _activeCall}');
    }
  }

  /**
   * Change the application to [newState]
   */
  void changeState(AppState newState) {
    _stateChange.fire(newState);
  }

  /**
   * Return the currently logged in user.
   */
  ORModel.User get currentUser => _currentUser;

  /**
   * Set the currently logged in user.
   */
  set currentUser(ORModel.User newUser) {
    _currentUser = newUser;
  }

  /**
   * Setup listeners needed for this object.
   */
  void _observers() {
    _notification.onAnyCallStateChange.listen((OREvent.CallEvent event) {
      final ORModel.Call call = event.call;

      if (call.assignedTo != currentUser.id) {
        return;
      }

      if (call.state == ORModel.CallState.Ringing ||
          call.state == ORModel.CallState.Speaking) {
        activeCall = call;
      } else if (activeCall == call) {
        activeCall = ORModel.Call.noCall;
      }
    });
  }

  /**
   * Listen for [AppState] change events.
   */
  Stream<AppState> get onStateChange => this._stateChange.stream;
}
