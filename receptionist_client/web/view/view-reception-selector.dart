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
 * The reception selector widget.
 */
class ReceptionSelector extends ViewWidget {
  final Model.AppClientState _appState;
  final Map<String, String> _langMap;
  final Controller.Destination _myDestination;
  final Controller.Popup _popup;
  final List<ORModel.Reception> _receptions;
  final Model.UIReceptionSelector _uiModel;

  /**
   * Constructor.
   */
  ReceptionSelector(
      Model.UIReceptionSelector this._uiModel,
      Model.AppClientState this._appState,
      Controller.Destination this._myDestination,
      List<ORModel.Reception> this._receptions,
      Controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _ui.setHint('alt+v');

    _ui.receptions = _receptions;

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIReceptionSelector get _ui => _uiModel;

  @override void _onBlur(_) {}
  @override void _onFocus(_) {}

  /**
   * Activate this widget if it's not already activated.
   */
  void _activateMe(_) {
    _navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltV.listen(_activateMe);

    _ui.onClick.listen(_activateMe);

    _ui.onSelectedRemoved.listen((ORModel.Reception reception) {
      _popup.info(
          _langMap[Key.selectedReceptionRemoved], '${reception.name} (${reception.ID.toString()})',
          closeAfter: new Duration(seconds: 5));
    });

    _ui.onSelectedUpdated.listen((ORModel.Reception reception) {
      _popup.info(
          _langMap[Key.selectedReceptionUpdated], '${reception.name} (${reception.ID.toString()})',
          closeAfter: new Duration(seconds: 5));
    });

    _appState.activeCallChanged.listen((ORModel.Call newCall) {
      if (newCall != ORModel.Call.noCall) {
        _ui.reset();
        _ui.changeActiveReception(newCall.receptionID);
      }
    });
  }
}
