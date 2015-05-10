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
class ContactCalendar extends ViewWidget {
  final Model.UIContactSelector   _contactSelector;
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactCalendar   _ui;
  final Controller.Contact        _contactController;

  /**
   * Constructor.
   */
  ContactCalendar(Model.UIModel this._ui,
                  Controller.Destination this._myDestination,
                  Model.UIContactSelector this._contactSelector,
                  Model.UIReceptionSelector this._receptionSelector,
                  Controller.Contact this._contactController) {
    _ui.setHint('alt+k');
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Empty the [CalendarEvent] list on null [Reception].
   */
  void clear(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
    }
  }

  /**
   * If a contact is selected in [_contactSelector], then navigate to the
   * calendar editor with [cmd] set.
   */
  void _maybeNavigateToEditor(Cmd cmd) {
    if(_contactSelector.selectedContact.isNotEmpty) {
      _navigate.goCalendarEdit(from: _myDestination..cmd = cmd);
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltK.listen(activateMe);

    _ui.onClick .listen(activateMe);
    _ui.onEdit  .listen((_) => _maybeNavigateToEditor(Cmd.EDIT));
    _ui.onNew   .listen((_) => _maybeNavigateToEditor(Cmd.NEW));

    _contactSelector.onSelect.listen(render);

    _receptionSelector.onSelect.listen(clear);
  }

  /**
   * Render the widget with [contact].
   */
  void render(Model.Contact contact) {
    if(contact.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = 'for ${contact.fullName}';

      this._contactController.getCalendar(contact)
        .then((Iterable<Model.ContactCalendarEntry> entries) {
          _ui.calendarEntries = entries.toList()
              ..sort((a,b) => a.startTime.compareTo(b.startTime));
        });
    }
  }
}
