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
 * The reception greeting widget.
 */
class WelcomeMessage extends ViewWidget {
  final Model.AppClientState _appState;
  final Map<String, String> _langMap;
  ORModel.Call _latestCall;
  final Controller.Notification _notification;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIWelcomeMessage _uiModel;

  /**
   * Constructor.
   */
  WelcomeMessage(
      Model.UIWelcomeMessage this._uiModel,
      Model.AppClientState this._appState,
      Model.UIReceptionSelector this._receptionSelector,
      Controller.Notification this._notification,
      Map<String, String> this._langMap) {
    _observers();
  }

  @override Controller.Destination get _destination => null;
  @override Model.UIWelcomeMessage get _ui => _uiModel;

  @override void _onBlur(_) {}
  @override void _onFocus(_) {}

  /**
   * Observers.
   */
  void _observers() {
    _receptionSelector.onSelect.listen(_render);

    _appState.activeCallChanged.listen((ORModel.Call newCall) {
      _ui.inActiveCall = newCall != ORModel.Call.noCall;
      if (newCall != ORModel.Call.noCall) {
        _latestCall = newCall;
      }
    });

    _notification.onAnyCallStateChange.listen((OREvent.CallEvent event) {
      if (event.call.assignedTo == _appState.currentUser.ID &&
          event.call.state == ORModel.CallState.Hungup &&
          _latestCall.ID == event.call.ID) {
        _ui.inActiveCall = false;
      }
    });
  }

  /**
   * Render the widget with [reception].
   */
  void _render(ORModel.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear();
      _ui.greeting = _langMap[Key.standardGreeting];
    } else {
      if (_appState.activeCall != ORModel.Call.noCall) {
        _ui.greeting =
            _appState.activeCall.greetingPlayed ? reception.greeting : reception.shortGreeting;
      } else {
        _ui.greeting = reception.greeting;
      }
    }
  }
}
