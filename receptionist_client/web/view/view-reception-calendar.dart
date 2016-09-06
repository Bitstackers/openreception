
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

part of orc.view;

/**
 * The reception calendar.
 */
class ReceptionCalendar extends ViewWidget {
  final controller.Destination _myDestination;
  final controller.Notification _notification;
  final controller.Calendar _calendarController;
  final ui_model.UIReceptionSelector _receptionSelector;
  final ui_model.UIReceptionCalendar _uiModel;

  /**
   * Constructor.
   */
  ReceptionCalendar(
      ui_model.UIReceptionCalendar this._uiModel,
      controller.Destination this._myDestination,
      ui_model.UIReceptionSelector this._receptionSelector,
      controller.Calendar this._calendarController,
      controller.Notification this._notification) {
    _ui.setHint('alt+a | ctrl+k | ctrl+e');

    _observers();
  }

  @override
  controller.Destination get _destination => _myDestination;
  @override
  void _onBlur(controller.Destination _) {}
  @override
  void _onFocus(controller.Destination _) {}
  @override
  ui_model.UIReceptionCalendar get _ui => _uiModel;

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe() {
    _navigateToMyDestination();
  }

  /**
   * Fetch all calendar entries for [reception].
   */
  void _fetchCalendar(model.ReceptionReference reception) {
    _calendarController
        .receptionCalendar(reception)
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

    _hotKeys.onAltA.listen((KeyboardEvent _) => _activateMe());
    _ui.onClick.listen((MouseEvent _) => _activateMe());

    _receptionSelector.onSelect.listen(_render);

    _notification.onCalendarChange.listen(_updateOnChange);
  }

  /**
   * Render the widget with [reception].
   */
  void _render(model.Reception reception) {
    if (reception.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = ': ${reception.name}';
      _fetchCalendar(reception.reference);
    }
  }

  /**
   * Check if changes to the reception calendar matches the currently selected
   * reception, and update accordingly if so.
   */
  void _updateOnChange(event.CalendarChange calendarChange) {
    final model.ReceptionReference currentReception =
        _receptionSelector.selectedReception;

    if (calendarChange.owner.id == currentReception.id) {
      _fetchCalendar(currentReception);
    }
  }
}
