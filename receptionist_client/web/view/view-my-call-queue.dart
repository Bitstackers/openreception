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
 * Show the my call queue and registers keyboard shortcuts for call handling.
 *
 * This reloads the call queue list at a fixed refresh rate of [_refreshRate].
 */
class MyCallQueue extends ViewWidget {
  final Model.AppClientState _appState;
  final Controller.Call _call;
  final Map<String, String> _langMap;
  final Controller.Destination _myDestination;
  final Controller.Notification _notification;
  final Controller.Popup _popup;
  final Model.UIMyCallQueue _uiModel;

  /**
   * Constructor.
   */
  MyCallQueue(
      Model.UIMyCallQueue this._uiModel,
      Model.AppClientState this._appState,
      Controller.Destination this._myDestination,
      Controller.Notification this._notification,
      Controller.Call this._call,
      Controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _loadCallList();

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIMyCallQueue get _ui => _uiModel;

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
  void _handleCallStateChanges(ORModel.Call call) {
    if (call.assignedTo != _appState.currentUser.ID) {
      return;
    }

    switch (call.state) {
      case ORModel.CallState.Created:
        if (!call.inbound) {
          /// My outbound call.
          _ui.appendCall(call);
        }
        break;

      case ORModel.CallState.Hungup:
      case ORModel.CallState.Transferred:
        _ui.removeCall(call);
        break;

      default:
        _ui.updateCall(call);
        break;
    }
  }

  /**
   * Load the list of calls assigned to current user and not being transferred.
   */
  void _loadCallList() {
    bool isMine(ORModel.Call call) =>
        call.assignedTo == _appState.currentUser.ID && call.state != ORModel.CallState.Transferred;

    _call.listCalls().then((Iterable<ORModel.Call> calls) {
      _ui.calls = calls.where(isMine).toList(growable: false);
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    bool callControllerBusy = false;

    _navigate.onGo.listen(_setWidgetState);

    _ui.onClick.listen(_activateMe);

    void _complete() {
      new Future.delayed(new Duration(milliseconds: 500), () => callControllerBusy = false);
    }

    void _error(Exception error, String title, String message) {
      if (error is Controller.BusyException) {
        _popup.error(_langMap[Key.errorSystem], _langMap[Key.errorCallControllerBusy]);
      } else {
        _popup.error(title, message);
      }

      _complete();
    }

    _hotKeys.onCtrlNumMinus.listen((_) {
      if (!callControllerBusy && _appState.activeCall != ORModel.Call.noCall) {
        callControllerBusy = true;
        _call
            .transferToFirstParkedCall(_appState.activeCall)
            .catchError((error) =>
                _error(error, _langMap[Key.errorCallTransfer], 'ID ${_appState.activeCall.ID}'))
            .whenComplete(() => _complete());
      }
    });

    _notification.onAnyCallStateChange.listen(_handleCallStateChanges);
  }
}
