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
  final Controller.Call           _callController;
  final Model.UIContactSelector   _contactSelector;
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactData       _ui;

  /**
   * Constructor.
   */
  ContactData(Model.UIContactData this._ui,
              Controller.Destination this._myDestination,
              Model.UIContactSelector this._contactSelector,
              Model.UIReceptionSelector this._receptionSelector,
              Controller.Call this._callController) {
    _ui.setHint('alt+t, ctrl+space');
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIContactData    get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is
   * already focused.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Tries to dial the [phoneNumber].
   *
   * This should be called when the [_ui] fires a [ORModel.PhoneNumber] as
   * marked ringing.
   */
  void _call(ORModel.PhoneNumber phoneNumber) {
    _callController.dial(
        phoneNumber,
        _receptionSelector.selectedReception,
        _contactSelector.selectedContact)
      .whenComplete(_ui.removeRinging);
  }

  /**
   * Clear the widget on null [Reception].
   */
  void clear(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltT.listen(activateMe);

    _ui.onClick.listen(activateMe);

    _contactSelector.onSelect.listen(render);

    _receptionSelector.onSelect.listen(clear);

    _hotKeys.onNumMult.listen(_setRinging);

    _ui.onMarkedRinging.listen(_call);
  }

  /**
   * Render the widget with [Contact].
   */
  void render(Model.Contact contact) {
    if(contact.isEmpty) {
      _ui.clear();
    } else {
      _ui.contact = contact;
      _ui.selectFirstPhoneNumber();
    }
  }

  /**
   * If no phonenumber is marked ringing, mark the currently selected phone-
   * number ringing.
   */
  void _setRinging(_) {
    ui.ring();
  }
}
