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
 * TODO (TL): Comment
 */
class ContactSelector extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactSelector   _uiModel;
  final Controller.Contact        _contactController;

  /**
   * Constructor.
   */
  ContactSelector(Model.UIContactSelector this._uiModel,
                  Controller.Destination this._myDestination,
                  Model.UIReceptionSelector this._receptionSelector,
                  Controller.Contact this._contactController) {
    _ui.setHint('alt+s');

    _observers();
  }

  @override Controller.Destination  get _destination => _myDestination;
  @override Model.UIContactSelector get _ui          => _uiModel;

  @override void _onBlur(_){}
  @override void _onFocus(_){}

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

    _hotKeys.onAltS.listen(_activateMe);

    _ui.onClick.listen(_activateMe);

    _receptionSelector.onSelect.listen(_render);
  }

  /**
   * Render the widget with [reception].
   */
  void _render(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
    } else {
      _contactController.list(reception)
          .then((Iterable<Model.Contact> contacts) {
            List<Model.Contact> sortedContacts = contacts.toList()
                ..sort((Model.Contact x , Model.Contact y) => x.fullName.compareTo(y.fullName));

            _ui.contacts = sortedContacts;
            _ui.selectFirstContact();
          });
    }
  }
}
