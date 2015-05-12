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
 * The calendar editor widget. Note that this handles editing of calendar entries
 * for both receptions and contacts.
 */
class CalendarEditor extends ViewWidget {
  final Model.UIContactCalendar   _contactCalendar;
  final Controller.Contact        _contactController;
  final Model.UIContactSelector   _contactSelector;
  final Map<String, String>       _langMap;
  final Logger                    _log = new Logger('$libraryName.CalendarEditor');
  final Controller.Destination    _myDestination;
  final Model.UIReceptionCalendar _receptionCalendar;
  final Controller.Reception      _receptionController;
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
                 Model.UIReceptionSelector this._receptionSelector,
                 Controller.Contact this._contactController,
                 Controller.Reception this._receptionController,
                 Map<String, String> this._langMap) {
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_) {
    if(_ui.isFocused) {
      _ui.reset();
    }
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
   * Close the widget and cancel edit/create calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void _close(_) {
    _ui.reset();
    window.history.back();
  }

  /**
   * Delete the calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void _delete(_) {
    Future deleteEntry;

    if(_ui.loadedEntry is Model.ReceptionCalendarEntry) {
      deleteEntry = _receptionController.deleteCalendarEvent(_ui.loadedEntry);
    } else if(_ui.loadedEntry is Model.ContactCalendarEntry) {
      deleteEntry = _contactController.deleteCalendarEvent(_ui.loadedEntry);
    }

    deleteEntry
      .then((_) => _log.info('${_ui.loadedEntry} successfully deleted from database'))
      .catchError((error) => _log.shout('Could not delete calendar entry ${_ui.loadedEntry}'))
      .whenComplete(() => _close(_));
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onCancel.listen(_close);
    _ui.onDelete.listen(_delete);
    _ui.onSave  .listen(_save);
  }

  /**
   * Save the calendar entry.
   *
   * Clear the form when done, and then navigate one step back in history.
   */
  void _save(_) {
    Future saveEntry;

    if(_ui.loadedEntry is Model.ReceptionCalendarEntry) {
      saveEntry = _receptionController.saveCalendarEvent(_ui.loadedEntry);
    } else if(_ui.loadedEntry is Model.ContactCalendarEntry) {
      saveEntry = _contactController.saveCalendarEvent(_ui.loadedEntry);
    }

    saveEntry
      .then((_) => _log.info('${_ui.loadedEntry} successfully saved to database'))
      .catchError((error) => _log.shout('Could not save calendar entry ${_ui.loadedEntry}'))
      .whenComplete(() => _close(_));
  }

  /**
   * Render the widget with [calendarEntry].
   */
  void _render(Model.CalendarEntry calendarEntry) {
    _ui.calendarEntry = calendarEntry;
  }

  /**
   * Setup the widget accordingly to where it was opened from. [from] MUST be
   * the [Widget] that activated CalendarEditor.
   *
   * This widget is only ever opened from other widgets, and as such we need to
   * know who activated us, in order to properly know how to find and deal
   * with the calendar entry we're either deleting/editing or creating.
   */
  void _setup(Widget from, Cmd cmd) {
    switch(from) {
      case Widget.ContactCalendar:
        if(cmd == Cmd.EDIT) {
          _ui.headerExtra = '(${_langMap[Key.editorEditDelete]})';
          _render(_contactCalendar.selectedCalendarEntry);
        } else {
          _ui.headerExtra = '(${_langMap[Key.editorNew]})';

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
          _ui.headerExtra = '(${_langMap[Key.editorEditDelete]})';
          _render(_receptionCalendar.selectedCalendarEntry);
        } else {
          _ui.headerExtra = '(${_langMap[Key.editorNew]})';
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
