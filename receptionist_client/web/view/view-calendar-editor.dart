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
  final Controller.Calendar       _calendarController;
  final Model.UIContactSelector   _contactSelector;
  final Map<String, String>       _langMap;
  final Logger                    _log = new Logger('$libraryName.CalendarEditor');
  final Controller.Destination    _myDestination;
  final Controller.Popup                     _popup;
  final Model.UIReceptionCalendar _receptionCalendar;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UICalendarEditor    _uiModel;

  /**
   * Constructor
   */
  CalendarEditor(Model.UICalendarEditor this._uiModel,
                 Controller.Destination this._myDestination,
                 Model.UIContactCalendar this._contactCalendar,
                 Model.UIContactSelector this._contactSelector,
                 Model.UIReceptionCalendar this._receptionCalendar,
                 Model.UIReceptionSelector this._receptionSelector,
                 Controller.Calendar  this._calendarController,
                 Controller.Popup this._popup,
                 Map<String, String> this._langMap) {
    _ui.setHint('Esc | ctrl+backspace | ctrl+s ');

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UICalendarEditor get _ui          => _uiModel;

  @override void _onBlur(_) {
    if(_ui.isFocused) {
      _ui.reset();
    }
  }

  /**
   * When we get focus, figure out where from we were called. If we weren't
   * called from anywhere ie. the [destination].from.widget is null, then
   * navigate to home.
   */
  @override void _onFocus(Controller.Destination destination){
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
    final ORModel.CalendarEntry loadedEntry = _ui.loadedEntry;

    _calendarController.deleteCalendarEvent(_ui.loadedEntry)
      .then((_) {
        _log.info('${loadedEntry} successfully deleted from database');
        _popup.success(_langMap[Key.calendarEditorDelSuccessTitle], 'ID ${loadedEntry.ID}');
      })
      .catchError((error) {
        _log.shout('Could not delete calendar entry ${loadedEntry}');
        _popup.error(_langMap[Key.calendarEditorDelErrorTitle], 'ID ${loadedEntry.ID}');
      })
      .whenComplete(() => _close(_));
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

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
    final ORModel.CalendarEntry entry = _ui.harvestedEntry;

    _calendarController.saveCalendarEvent(entry)
      .then((ORModel.CalendarEntry savedEntry) {
        _log.info('${savedEntry} successfully saved to database');
        _popup.success(_langMap[Key.calendarEditorSaveSuccessTitle], 'ID ${savedEntry.ID}');
      })
      .catchError((error) {
        ORModel.CalendarEntry loadedEntry = _ui.loadedEntry;
        _log.shout('Could not save calendar entry ${loadedEntry}');
        _popup.error(_langMap[Key.calendarEditorSaveErrorTitle], 'ID ${loadedEntry.ID}');
      })
      .whenComplete(() => _close(_));
  }

  /**
   * Render the widget with [calendarEntry].
   */
  void _render(ORModel.CalendarEntry calendarEntry) {
    _ui.calendarEntry = calendarEntry;
  }

  /**
   * Set the [_ui.authorStamp]. This is populated with data from the latest
   * calendar entry change object for [entryId].
   */
  void _setAuthorStamp(ORModel.CalendarEntry entry) {
    _calendarController.calendarEntryLatestChange(entry)
        .then((ORModel.CalendarEntryChange latestChange) {
          _ui.authorStamp(latestChange.username, latestChange.changedAt);
        });
  }

  /**
   * Setup the widget accordingly to where it was opened from. [from] MUST be
   * the [Controller.Widget] that activated CalendarEditor.
   *
   * This widget is only ever opened from other widgets, and as such we need to
   * know who activated us, in order to properly know how to find and deal
   * with the calendar entry we're either deleting/editing or creating.
   */
  void _setup(Controller.Widget from, Controller.Cmd cmd) {
    ORModel.CalendarEntry entry;

    switch(from) {
      case Controller.Widget.ContactCalendar:
        if(cmd == Controller.Cmd.EDIT) {
          entry = _contactCalendar.selectedCalendarEntry;

          _ui.headerExtra = '(${_langMap[Key.editDelete]})';
          _setAuthorStamp(entry);

          _render(entry);
        } else {
          entry = new ORModel.CalendarEntry.contact
              (_contactSelector.selectedContact.ID,
               _receptionSelector.selectedReception.ID)
                    ..beginsAt = new DateTime.now()
                    ..until = new DateTime.now().add(new Duration(hours : 1))
                    ..content = '';

          _ui.headerExtra = '(${_langMap[Key.editorNew]})';
          _ui.authorStamp(null, null);

          _render(entry);
        }
        break;
      case Controller.Widget.ReceptionCalendar:
        if(cmd == Controller.Cmd.EDIT) {
          entry = _receptionCalendar.selectedCalendarEntry;

          _ui.headerExtra = '(${_langMap[Key.editDelete]})';
          _setAuthorStamp(entry);

          _render(entry);
        } else {
          entry = new ORModel.CalendarEntry.reception
              (_receptionSelector.selectedReception.ID)
                    ..beginsAt = new DateTime.now()
                    ..until = new DateTime.now().add(new Duration(hours : 1))
                    ..content = '';

          _ui.headerExtra = '(${_langMap[Key.editorNew]})';
          _ui.authorStamp(null, null);

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
