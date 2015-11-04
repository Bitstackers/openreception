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
  final Controller.Call _call;
  bool _callControllerBusy = false;
  final Map<String, String> _langMap;
  final Controller.Destination _myDestination;
  final Controller.Notification _notification;
  final Controller.Popup _popup;
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
      Controller.Call this._call,
      Controller.Popup this._popup,
      Controller.Sound this._sound,
      ORModel.UserStatus this._userState,
      Map<String, String> this._langMap) {
    _loadCallList();

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIGlobalCallQueue get _ui => _uiModel;

  @override void _onBlur(_) {}
  @override void _onFocus(_) {}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe(_) {
    _navigateToMyDestination();
  }

  /**
   * Add, remove, update the queue list, depending on the [call] state.
   */
  void _handleCallStateChanges(OREvent.CallEvent event) {
    final ORModel.Call call = event.call;

    if(event is OREvent.CallOffer) {
      _ui.appendCall(call);
    } else if (event is OREvent.CallHangup) {
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

    _call.listCalls().then((Iterable<ORModel.Call> calls) {
      _ui.calls = calls.where(unassigned).toList(growable: false);
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.onClick.listen(_activateMe);

    _notification.onAnyCallStateChange.listen(_handleCallStateChanges);

    void _complete() {
      new Future.delayed(new Duration(milliseconds: 500), () => _callControllerBusy = false);
    }

    void _error(Exception error, String title, String message) {
      if (error is Controller.BusyException) {
        _popup.error(_langMap[Key.errorSystem], _langMap[Key.errorCallControllerBusy]);
      } else {
        _popup.error(title, message);
      }

      _complete();
    }

    /**
     *
     */
    _notification.onAgentStateChange.listen((ORModel.UserStatus userStatus) {
      if (userStatus.userID == _appState.currentUser.ID) {
        _userState = userStatus;
      }
    });

    /**
     * Play the pling sound every 2 seconds if
     *
     *  there are calls in the queueu AND
     *  appState.activeCall is NOT noCall AND
     *  the agent state is idle or unknown.
     */
    new Timer.periodic(new Duration(seconds: 2), (_) {
      if (_ui.hasCalls &&
          _appState.activeCall == ORModel.Call.noCall &&
          (_userState.state == ORModel.UserState.Idle ||
              _userState.state == ORModel.UserState.Unknown)) {
        _sound.pling();
      }
    });

    _hotKeys.onNumPlus.listen((_) {
      if (!_callControllerBusy) {
        _callControllerBusy = true;
        _call
            .pickupNext()
            .catchError((error) => _error(
                error, _langMap[Key.errorCallNotFound], _langMap[Key.errorCallNotFoundExtended]))
            .whenComplete(() => _complete());
      }
    });

    _hotKeys.onNumDiv.listen((_) {
      if (!_callControllerBusy && _appState.activeCall != ORModel.Call.noCall) {
        _callControllerBusy = true;
        _call
            .hangup(_appState.activeCall)
            .catchError((error) =>
                _error(error, _langMap[Key.errorCallHangup], 'ID ${_appState.activeCall.ID}'))
            .whenComplete(() => _complete());
      }
    });

    _hotKeys.onF7.listen((_) {
      if (!_callControllerBusy && _appState.activeCall != ORModel.Call.noCall) {
        _callControllerBusy = true;
        _call
            .park(_appState.activeCall)
            .catchError((error) =>
                _error(error, _langMap[Key.errorCallPark], 'ID ${_appState.activeCall.ID}'))
            .whenComplete(() => _complete());
      }
    });

    _hotKeys.onF8.listen((_) {
      if (!_callControllerBusy) {
        _callControllerBusy = true;
        _call
            .pickupFirstParkedCall()
            .catchError((error) => _error(error, _langMap[Key.errorCallUnpark], ''))
            .whenComplete(() => _complete());
      }
    });
  }
}
