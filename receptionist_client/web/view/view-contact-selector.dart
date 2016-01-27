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
  final Controller.Destination _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactSelector _uiModel;
  final Controller.Contact _contactController;

  /**
   * Constructor.
   */
  ContactSelector(
      Model.UIContactSelector this._uiModel,
      Controller.Destination this._myDestination,
      Model.UIReceptionSelector this._receptionSelector,
      Controller.Contact this._contactController) {
    _ui.setHint('alt+s');

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIContactSelector get _ui => _uiModel;

  @override void _onBlur(Controller.Destination _) {}
  @override void _onFocus(Controller.Destination _) {}

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
  void _render(ORModel.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear();
    } else {
      _contactController.list(reception).then((Iterable<ORModel.Contact> contacts) {
        int nameSort(ORModel.Contact x, ORModel.Contact y) =>
            x.fullName.toLowerCase().compareTo(y.fullName.toLowerCase());

        final List<ORModel.Contact> functionContacts = contacts
            .where(
                (ORModel.Contact contact) => contact.enabled && contact.contactType == 'function')
            .toList()..sort(nameSort);
        final List<ORModel.Contact> humanContacts = contacts
            .where((ORModel.Contact contact) => contact.enabled && contact.contactType == 'human')
            .toList()..sort(nameSort);
        final List<ORModel.Contact> disabledContacts =
            contacts.where((ORModel.Contact contact) => !contact.enabled).toList()..sort(nameSort);

        _ui.contacts = new List<ORModel.Contact>()
          ..addAll(functionContacts)
          ..addAll(humanContacts)
          ..addAll(disabledContacts);

        _ui.selectFirstContact();
      });
    }
  }
}
