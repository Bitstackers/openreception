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

part of orc.view;

/**
 * The reception greeting widget.
 */
class WelcomeMessage extends ViewWidget {
  final ui_model.AppClientState _appState;
  final Map<String, String> _langMap;
  final ui_model.UIReceptionSelector _receptionSelector;
  final ui_model.UIWelcomeMessage _uiModel;

  /**
   * Constructor.
   */
  WelcomeMessage(
      ui_model.UIWelcomeMessage this._uiModel,
      ui_model.AppClientState this._appState,
      ui_model.UIReceptionSelector this._receptionSelector,
      Map<String, String> this._langMap) {
    _observers();
  }

  @override
  controller.Destination get _destination => null;
  @override
  ui_model.UIWelcomeMessage get _ui => _uiModel;

  @override
  void _onBlur(controller.Destination _) {}
  @override
  void _onFocus(controller.Destination _) {}

  /**
   * Observers.
   */
  void _observers() {
    _receptionSelector.onSelect.listen(_render);

    _appState.activeCallChanged.listen((model.Call newCall) {
      _ui.inActiveCall = newCall != model.Call.noCall;
    });
  }

  /**
   * Render the widget with [reception].
   */
  void _render(model.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear();
      _ui.greeting = _langMap[Key.standardGreeting];
    } else {
      if (_appState.activeCall != model.Call.noCall) {
        _ui.greeting = _appState.activeCall.greetingPlayed
            ? reception.greeting
            : reception.shortGreeting;
      } else {
        _ui.greeting = reception.greeting;
      }
    }
  }
}
