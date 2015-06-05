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
 * The reception calendar.
 */
class ReceptionCalendar extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Controller.Notification   _notification;
  final Controller.Reception      _receptionController;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIReceptionCalendar _uiModel;

  /**
   * Constructor.
   */
  ReceptionCalendar(Model.UIReceptionCalendar this._uiModel,
                    Controller.Destination this._myDestination,
                    Model.UIReceptionSelector this._receptionSelector,
                    Controller.Reception this._receptionController,
                    Controller.Notification this._notification) {
    _ui.setHint('alt+a');

    _observers();
  }

  @override Controller.Destination    get _destination => _myDestination;
  @override Model.UIReceptionCalendar get _ui          => _uiModel;

  @override void _onBlur(_){}
  @override void _onFocus(_){}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe(_) {
    _navigateToMyDestination();
  }

  /**
   * Fetch all calendar entries for [reception].
   */
  void _fetchCalendar(Model.Reception reception) {
    _receptionController.calendar(reception)
      .then ((Iterable<Model.ReceptionCalendarEntry> entries) {
        _ui.calendarEntries = entries.toList()
            ..sort((a,b) => a.start.compareTo(b.start));
      });
  }

  /**
   * If a contact is selected in [_contactSelector], then navigate to the
   * calendar editor with [cmd] set.
   */
  void _maybeNavigateToEditor(Controller.Cmd cmd) {
    if(_receptionSelector.selectedReception.isNotEmpty) {
      _navigate.goCalendarEdit(from: _myDestination..cmd = cmd);
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onAltA.listen(_activateMe);

    _ui.onClick.listen(_activateMe);
    _ui.onEdit .listen((_) => _maybeNavigateToEditor(Controller.Cmd.EDIT));
    _ui.onNew  .listen((_) => _maybeNavigateToEditor(Controller.Cmd.NEW));

    _receptionSelector.onSelect.listen(_render);

    _notification.onCalendarChange.listen(_updateOnChange);
  }

  /**
   * Render the widget with [reception].
   */
  void _render(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = ': ${reception.name}';
      _fetchCalendar(reception);
    }
  }

  /**
   * Check if changes to the reception calendar matches the currently selected
   * reception, and update accordingly if so.
   */
  void _updateOnChange(OREvent.CalendarChange calendarChange) {
    final Model.Reception currentReception = _receptionSelector.selectedReception;

    if(calendarChange.receptionID == currentReception.ID) {
      _fetchCalendar(currentReception);
    }
  }
}
