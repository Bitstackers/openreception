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
 * The reception type/kind widget.
 */
class ReceptionType extends ViewWidget {
  final Map<String, String> _langMap;
  final controller.Destination _myDestination;
  final ui_model.UIReceptionSelector _receptionSelector;
  final ui_model.UIReceptionType _uiModel;

  /**
   * Constructor.
   */
  ReceptionType(
      ui_model.UIReceptionType this._uiModel,
      controller.Destination this._myDestination,
      ui_model.UIReceptionSelector this._receptionSelector,
      Map<String, String> this._langMap) {
    _observers();
  }

  @override
  controller.Destination get _destination => _myDestination;
  @override
  ui_model.UIReceptionType get _ui => _uiModel;

  @override
  void _onBlur(controller.Destination _) {}
  @override
  void _onFocus(controller.Destination _) {}

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

    _ui.onClick.listen((MouseEvent _) => _activateMe());

    _receptionSelector.onSelect.listen(_render);
  }

  /**
   * Render the widget with [reception].
   */
  void _render(model.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = ': ${reception.name}';
      _ui.type = []
        ..addAll(reception.customerTypes)
        ..add('${_langMap[Key.theirNumber]}: ${reception.dialplan}');
    }
  }
}
