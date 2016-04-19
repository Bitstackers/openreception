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
 * The ORC loading "widget". Activates on AppState.LOADING
 */
class ORCLoading {
  final Model.AppClientState _appState;
  static ORCLoading _singleton;
  final Model.UIORCLoading _ui;

  /**
   * Constructor.
   */
  factory ORCLoading(
      Model.AppClientState appState, Model.UIORCLoading uiLoading) {
    if (_singleton == null) {
      _singleton = new ORCLoading._internal(appState, uiLoading);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ORCLoading._internal(
      Model.AppClientState this._appState, Model.UIORCLoading this._ui) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((Model.AppState appState) => appState ==
        Model.AppState.loading ? _ui.visible = true : _ui.visible = false);
  }
}
