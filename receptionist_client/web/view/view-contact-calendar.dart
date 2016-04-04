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
 * Handles the contact calendar entries.
 */
class ContactCalendar extends ViewWidget {
  final Model.UIContactSelector _contactSelector;
  ORModel.Contact _latestContact = new ORModel.Contact.empty();
  final Controller.Destination _myDestination;
  final Controller.Notification _notification;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactCalendar _uiModel;
  final Controller.Contact _contactController;
  final Controller.Calendar _calendarController;

  /**
   * Constructor.
   */
  ContactCalendar(
      Model.UIContactCalendar this._uiModel,
      Controller.Destination this._myDestination,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionSelector this._receptionSelector,
      Controller.Contact this._contactController,
      Controller.Calendar this._calendarController,
      Controller.Notification this._notification) {
    _ui.setHint('alt+k | ctrl+k | ctrl+e');

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIContactCalendar get _ui => _uiModel;

  @override void _onBlur(Controller.Destination _) {}
  @override void _onFocus(Controller.Destination _) {}

  /**
   * Activate this widget if it's not already activated.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Empty the [CalendarEvent] list on null [Reception].
   */
  void _clear(ORModel.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear();
    }
  }

  /**
   * Fetch all calendar entries for [contact].
   */
  void _fetchCalendar(ORModel.Contact contact) {
    _calendarController
        .contactCalendar(contact)
        .then((Iterable<ORModel.CalendarEntry> entries) {
      _ui.calendarEntries = entries.toList()
        ..sort((a, b) => a.start.compareTo(b.start));
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltK.listen((KeyboardEvent _) => _activateMe());
    _ui.onClick.listen((MouseEvent _) => _activateMe());

    _notification.onCalendarChange.listen(_updateOnChange);

    _contactSelector.onSelect
        .listen((Model.ContactWithFilterContext c) => _render(c.contact));

    _receptionSelector.onSelect.listen(_clear);
  }

  /**
   * Render the widget with [contact].
   */
  void _render(ORModel.Contact contact) {
    if (_latestContact.ID != contact.ID) {
      _latestContact = contact;

      if (contact.isEmpty) {
        _ui.clear();
      } else {
        _ui.headerExtra = ': ${contact.fullName}';
        _fetchCalendar(contact);
      }
    }
  }

  /**
   * Check if changes to the contact calendar matches the currently selected
   * contact, and update accordingly if so.
   */
  void _updateOnChange(OREvent.CalendarChange calendarChange) {
    final ORModel.Contact currentContact = _contactSelector.selectedContact;

    if (calendarChange.contactID == currentContact.ID) {
      _fetchCalendar(currentContact);
    }
  }
}
