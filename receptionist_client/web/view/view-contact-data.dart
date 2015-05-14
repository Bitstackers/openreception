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
class ContactData extends ViewWidget {
  final Model.UIContactSelector   _contactSelector;
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactData       _ui;

  /**
   * Constructor.
   */
  ContactData(Model.UIModel this._ui,
              Controller.Destination this._myDestination,
              Model.UIContactSelector this._contactSelector,
              Model.UIReceptionSelector this._receptionSelector) {
    _ui.setHint('alt+t');
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

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

    _ui.onMarkedRinging.listen(_call);
    ///
    ///
    ///
    /// TODO (TL): Listen for call notifications here? Possibly mark ringing?
    /// Or put this in model-ui-contact-data.dart?
    ///
    ///
    ///
  }

  /**
   * Render the widget with [Contact].
   */
  void render(Model.Contact contact) {
    if(contact.isEmpty) {
      _ui.clear();
    } else {
      _ui.clear();

      _ui.headerExtra = 'for ${contact.fullName}';

      _ui.additionalInfo = ['additionalInfo 1', 'additionalInfo 2'];
      _ui.backups = ['backup 1', 'backup 2'];
      _ui.commands = ['command 1', 'command 2'];
      _ui.departments = ['department 1', 'department 2'];
      _ui.emailAddresses = ['thomas@responsum.dk', 'thomas.granvej6@gmail.com'];
      _ui.relations = ['Hustru: Trine Løcke', 'Far: Steen Løcke'];
      _ui.responsibility = ['Teknik og skidt der generelt ikke fungerer', 'Regelmæssig genstart af Windows'];
      _ui.tags = contact.tags;
      _ui.telephoneNumbers = [new TelNum('45454545', 'some number', false),
                              new TelNum('23456768', 'secret stuff', true),
                              new TelNum('60431992', 'personal cell', false),
                              new TelNum('60431993', 'wife cell', false)];
      _ui.titles = ['Nørd', 'Tekniker'];
      _ui.workHours = ['Hele tiden', 'Svarer sjældent telefonen om lørdagen'];

      _ui.selectFirstTelNum();
    }
  }

  /**
   * This is called when the [_ui] fires a [TelNum] as marked ringing.
   */
  void _call(TelNum telNum) {
    print('view-contact-data.call() ${telNum}');
    /// TODO (TL): Call the Controller layer to actually get the call going.
  }
}
