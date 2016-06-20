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
 * The ORC disaster "widget". Activates on AppState.ERROR
 */
class ORCDisaster {
  final Model.AppClientState _appState;
  static ORCDisaster _singleton;
  Model.UIORCDisaster _ui;

  /**
   * Constructor.
   */
  factory ORCDisaster(
      Model.AppClientState appClientState, Model.UIORCDisaster uiDisaster) {
    if (_singleton == null) {
      _singleton = new ORCDisaster._internal(appClientState, uiDisaster);
    }

    return _singleton;
  }

  /**
   * Internal constructor.
   */
  ORCDisaster._internal(
      Model.AppClientState this._appState, Model.UIORCDisaster this._ui) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((Model.AppState appState) => appState ==
        Model.AppState.error ? _ui.visible = true : _ui.visible = false);
  }
}
