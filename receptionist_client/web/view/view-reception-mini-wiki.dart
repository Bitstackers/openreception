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
 * The reception mini wiki.
 */
class ReceptionMiniWiki extends ViewWidget {
  final Controller.Destination _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIReceptionMiniWiki _uiModel;

  /**
   * Constructor.
   */
  ReceptionMiniWiki(
      Model.UIReceptionMiniWiki this._uiModel,
      Controller.Destination this._myDestination,
      Model.UIReceptionSelector this._receptionSelector) {
    _ui.setHint('alt+m');

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIReceptionMiniWiki get _ui => _uiModel;

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
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltM.listen((KeyboardEvent _) => _activateMe());
    _ui.onClick.listen((MouseEvent _) => _activateMe());

    _receptionSelector.onSelect.listen(_render);
  }

  /**
   * Render the widget with [reception].
   */
  void _render(ORModel.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = ': ${reception.name}';
      _ui.miniWiki = reception.miniWiki;
    }
  }
}
