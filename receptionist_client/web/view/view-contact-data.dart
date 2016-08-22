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
 * Provides methods for handling the contact data widget in terms of focus,
 * navigation and rendering via the UIContactData class.
 */
class ContactData extends ViewWidget {
  final ui_model.UIContactSelector _contactSelector;
  final Map<String, String> _langMap;
  final controller.Destination _myDestination;
  final controller.Popup _popup;
  final ui_model.UIReceptionSelector _receptionSelector;
  final ui_model.UIContactData _uiModel;

  /**
   * Constructor.
   */
  ContactData(
      ui_model.UIContactData this._uiModel,
      controller.Destination this._myDestination,
      ui_model.UIContactSelector this._contactSelector,
      ui_model.UIReceptionSelector this._receptionSelector,
      controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _ui.setHint('alt+t | ctrl+space |  alt+↑↓');

    _observers();
  }

  @override
  controller.Destination get _destination => _myDestination;
  @override
  void _onBlur(controller.Destination _) {}
  @override
  void _onFocus(controller.Destination _) {}
  @override
  ui_model.UIContactData get _ui => _uiModel;

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is
   * already focused.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Clear the widget on null [model.Reception].
   */
  void _clear(model.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear(removePopup: true);
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltT.listen((KeyboardEvent _) => _activateMe());
    _ui.onClick.listen((MouseEvent _) => _activateMe());

    _contactSelector.onSelect.listen(_render);

    _receptionSelector.onSelect.listen(_clear);
  }

  /**
   * Render the widget with [Contact].
   */
  void _render(ui_model.ContactWithFilterContext cwfc) {
    if (cwfc.contact.isEmpty) {
      _ui.clear(removePopup: false);
    } else {
      _ui.contactWithFilterContext = cwfc;
      _ui.selectFirstPhoneNumber();
    }
  }
}
