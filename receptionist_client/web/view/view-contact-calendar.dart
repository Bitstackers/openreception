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
  final ui_model.UIContactSelector _contactSelector;
  final controller.Destination _myDestination;
  final controller.Notification _notification;
  final ui_model.UIReceptionSelector _receptionSelector;
  final ui_model.UIContactCalendar _uiModel;
  final controller.Contact _contactController;
  final controller.Calendar _calendarController;

  /**
   * Constructor.
   */
  ContactCalendar(
      ui_model.UIContactCalendar this._uiModel,
      controller.Destination this._myDestination,
      ui_model.UIContactSelector this._contactSelector,
      ui_model.UIReceptionSelector this._receptionSelector,
      controller.Contact this._contactController,
      controller.Calendar this._calendarController,
      controller.Notification this._notification) {
    _ui.setHint('alt+k | ctrl+k | ctrl+e');

    _observers();
  }

  @override
  controller.Destination get _destination => _myDestination;
  @override
  void _onBlur(controller.Destination _) {}
  @override
  void _onFocus(controller.Destination _) {}
  @override
  ui_model.UIContactCalendar get _ui => _uiModel;

  /**
   * Activate this widget if it's not already activated.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Empty the [model.CalendarEntry] list on when [model.Reception] is empty.
   */
  void _clear(model.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear();
    }
  }

  /**
   * Fetch all calendar entries for [contact].
   */
  void _fetchCalendar(model.BaseContact contact) {
    _calendarController
        .contactCalendar(contact)
        .then((Iterable<model.CalendarEntry> entries) {
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
        .listen((ui_model.ContactWithFilterContext c) => _render(c.contact));

    _receptionSelector.onSelect.listen(_clear);
  }

  /**
   * Render the widget with [contact].
   */
  void _render(model.BaseContact contact) {
    if (contact.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = ': ${contact.name}';
      _fetchCalendar(contact);
    }
  }

  /**
   * Check if changes to the contact calendar matches the currently selected
   * contact, and update accordingly if so.
   */
  void _updateOnChange(event.CalendarChange calendarChange) {
    final model.BaseContact currentContact =
        _contactSelector.selectedContact.contact;

    if (calendarChange.owner is model.OwningContact &&
        calendarChange.owner.id == currentContact.id) {
      _fetchCalendar(currentContact);
    }
  }
}
