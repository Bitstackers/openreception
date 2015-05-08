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
class CalendarEditor extends ViewWidget {
  final Model.UIContactCalendar   _contactCalendar;
  final Model.UIContactSelector   _contactSelector;
  final Controller.Destination    _myDestination;
  final Model.UIReceptionCalendar _receptionCalendar;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UICalendarEditor    _ui;

  /**
   * Constructor
   */
  CalendarEditor(Model.UICalendarEditor this._ui,
                 Controller.Destination this._myDestination,
                 Model.UIContactCalendar this._contactCalendar,
                 Model.UIContactSelector this._contactSelector,
                 Model.UIReceptionCalendar this._receptionCalendar,
                 Model.UIReceptionSelector this._receptionSelector) {
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_) {
    _ui.reset();
  }

  /**
   * When we get focus, figure out where from we were called. If we weren't
   * called from anywhere ie. the [destination].from.widget is null, then
   * navigate to home.
   */
  @override void onFocus(Controller.Destination destination){
    if(destination.from != null) {
      _setup(destination.from.widget, destination.cmd);
    } else {
      _navigate.goHome();
    }
  }

  /**
   * Cancel edit/create calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void _cancel(_) {
    /// TODO (TL):
    /// Clear form.
    /// Set focusElement to default.
    if(_ui.isFocused) {
      window.history.back();
      print('view.CalendarEditor._cancel not fully implemented');
    }
  }

  /**
   * Delete the calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void _delete(_) {
    /// TODO (TL):
    /// Delete calendar entry.
    /// Call _cancel().
    print('view.CalendarEditor._delete not fully implemented');
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onCancel.listen(_cancel);
    _ui.onDelete.listen(_delete);
    _ui.onSave  .listen(_save);
  }

  /**
   * Save the calendar entry.
   *
   * Clear the form when done, and then navigate one step back in history.
   */
  void _save(_) {
    /// TODO (TL):
    /// Validate input data
    /// Save calendar entry.
    /// Call _cancel().
    print('view.CalendarEditor._save not fully implemented');
  }

  /**
   * Render the widget with [calendarEntry].
   */
  void _render(Model.CalendarEntry calendarEntry) {
    _ui.calendarEntry = calendarEntry;
  }

  /**
   * Setup the widget accordingly to where it was opened from. [initiator] MUST
   * be the [Widget] that activated CalendarEditor.
   *
   * This widget is only ever opened from other widgets, and as such we need to
   * know who activated us, in order to properly know how to find and deal
   * with the calendar entry we're either deleting/editing or creating.
   */
  void _setup(Widget initiator, Cmd cmd) {
    switch(initiator) {
      case Widget.ContactCalendar:
        if(cmd == Cmd.EDIT) {
          _ui.headerExtra = '(ret/slet)';
          _render(_contactCalendar.selectedCalendarEntry);
        } else {
          _ui.headerExtra = '(ny)';
          final Model.ContactCalendarEntry entry = new Model.ContactCalendarEntry
            (_contactSelector.selectedContact.ID, _receptionSelector.selectedReception.ID)
              ..beginsAt = new DateTime.now()
              ..until = new DateTime.now().add(new Duration(hours : 1))
              ..content = '';
          
          _render(entry);
        }
        break;
      case Widget.ReceptionCalendar:
        if(cmd == Cmd.EDIT) {
          _ui.headerExtra = '(ret/slet)';
          _render(_receptionCalendar.selectedCalendarEntry);
        } else {
          _ui.headerExtra = '(ny)';
          final Model.ReceptionCalendarEntry entry = new Model.ReceptionCalendarEntry
            (_receptionSelector.selectedReception.ID)
              ..beginsAt = new DateTime.now()
              ..until = new DateTime.now().add(new Duration(hours : 1))
              ..content = '';
          
          _render(entry);
        }
        break;
      default:
        /// No valid initiator. Go home.
        _navigate.goHome();
        break;
    }
  }
}
