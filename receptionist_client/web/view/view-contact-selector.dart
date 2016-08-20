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
 * Provides methods for manipulating the contact selector UI widget.
 */
class ContactSelector extends ViewWidget {
  final controller.Destination _myDestination;
  final ui_model.UIReceptionSelector _receptionSelector;
  final ui_model.UIContactSelector _uiModel;
  final controller.Contact _contactController;

  /**
   * Constructor.
   */
  ContactSelector(
      ui_model.UIContactSelector this._uiModel,
      controller.Destination this._myDestination,
      ui_model.UIReceptionSelector this._receptionSelector,
      controller.Contact this._contactController) {
    _ui.setHint('alt+s');

    _observers();
  }

  @override
  controller.Destination get _destination => _myDestination;
  @override
  ui_model.UIContactSelector get _ui => _uiModel;

  @override
  void _onBlur(controller.Destination _) {}
  @override
  void _onFocus(controller.Destination _) {}

  /**
   * Activate this widget if it's not already activated.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltS.listen((KeyboardEvent _) => _activateMe());
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
      _contactController
          .list(reception.reference)
          .then((Iterable<model.ReceptionContact> contacts) {
        int nameSort(model.ReceptionContact x, model.ReceptionContact y) =>
            x.contact.name
                .toLowerCase()
                .compareTo(y.contact.name.toLowerCase());

        final List<model.ReceptionContact> functionContacts = contacts
            .where((model.ReceptionContact rc) =>
                rc.contact.enabled && rc.contact.type == 'function')
            .toList()..sort(nameSort);
        final List<model.ReceptionContact> humanContacts = contacts
            .where((model.ReceptionContact rc) =>
                rc.contact.enabled && rc.contact.type == 'human')
            .toList()..sort(nameSort);
        final List<model.ReceptionContact> disabledContacts = contacts
            .where((model.ReceptionContact rc) => !rc.contact.enabled)
            .toList()..sort(nameSort);

        _ui.contacts = new List<model.ReceptionContact>()
          ..addAll(functionContacts)
          ..addAll(humanContacts)
          ..addAll(disabledContacts);

        _ui.selectFirstContact();
      });
    }
  }
}
