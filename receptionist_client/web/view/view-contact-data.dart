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
 * Provides methods for handling the contact data widget in terms of focus, navigation and rendering
 * via the UIContactData class.
 */
class ContactData extends ViewWidget {
  final Controller.Call _callController;
  final Model.UIContactSelector _contactSelector;
  final Map<String, String> _langMap;
  final Controller.Destination _myDestination;
  final Controller.Popup _popup;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactData _uiModel;

  /**
   * Constructor.
   */
  ContactData(
      Model.UIContactData this._uiModel,
      Controller.Destination this._myDestination,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionSelector this._receptionSelector,
      Controller.Call this._callController,
      Controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _ui.setHint('alt+t | ctrl+space |  alt+↑↓');

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIContactData get _ui => _uiModel;

  @override void _onBlur(_) {}
  @override void _onFocus(_) {}

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is already focused.
   */
  void _activateMe(_) {
    _navigateToMyDestination();
  }

  /**
   * Tries to dial the [phoneNumber].
   *
   * This should be called when the [_ui] fires a [ORModel.PhoneNumber] as marked ringing.
   */
  void _call(ORModel.PhoneNumber phoneNumber) {
    _callController
        .dial(phoneNumber, _receptionSelector.selectedReception, _contactSelector.selectedContact)
        .then((ORModel.Call call) {
      print('CALL: ${call.toJson()}');
    }).catchError((error) {
      _popup.error(_langMap[Key.callFailed], phoneNumber.value);
      throw error;
    }).whenComplete(_ui.removeRinging);
  }

  /**
   * Clear the widget on null [Reception].
   */
  void _clear(ORModel.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear(removePopup: true);
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltT.listen(_activateMe);

    _ui.onClick.listen(_activateMe);

    _contactSelector.onSelect.listen(_render);

    _receptionSelector.onSelect.listen(_clear);

    _hotKeys.onNumMult.listen(_setRinging);

    _ui.onMarkedRinging.listen(_call);
  }

  /**
   * Render the widget with [Contact].
   */
  void _render(ORModel.Contact contact) {
    if (contact.isEmpty) {
      _ui.clear(removePopup: true);
    } else {
      _ui.contact = contact;
      _ui.selectFirstPhoneNumber();
    }
  }

  /**
   * If no phonenumber is marked ringing, mark the currently selected phone number ringing.
   */
  void _setRinging(_) {
    _ui.ring();
  }
}
