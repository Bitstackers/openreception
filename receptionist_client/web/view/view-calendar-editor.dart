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
  final Model.UIContactCalendar _contactCalendar;
  final Controller.Calendar _calendarController;
  final Model.UIContactSelector _contactSelector;
  ORModel.Owner _entryOwner;
  final Map<String, String> _langMap;
  final Logger _log = new Logger('$libraryName.CalendarEditor');
  final Controller.Destination _myDestination;
  final Controller.Popup _popup;
  final Model.UIReceptionCalendar _receptionCalendar;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UICalendarEditor _uiModel;

  /**
   * Constructor
   */
  CalendarEditor(
      Model.UICalendarEditor this._uiModel,
      Controller.Destination this._myDestination,
      Model.UIContactCalendar this._contactCalendar,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionCalendar this._receptionCalendar,
      Model.UIReceptionSelector this._receptionSelector,
      Controller.Calendar this._calendarController,
      Controller.Popup this._popup,
      Map<String, String> this._langMap) {
    _ui.setHint('Esc | ctrl+backspace | ctrl+s ');

    _observers();
  }

  @override
  Controller.Destination get _destination => _myDestination;
  @override
  void _onBlur(Controller.Destination _) {}
  @override
  void _onFocus(Controller.Destination _) {}
  @override
  Model.UICalendarEditor get _ui => _uiModel;

  /**
   * Activate this widget if it's not already activated.
   *
   * Sets the entry owner.
   */
  void _activateMe(Controller.Cmd cmd) {
    if (_receptionSelector.selectedReception != ORModel.Reception.noReception) {
      if (_receptionCalendar.isFocused) {
        _entryOwner = new ORModel.OwningReception(
            _receptionSelector.selectedReception.id);
        _setup(Controller.Widget.receptionCalendar, cmd);
      } else {
        _entryOwner = new ORModel.OwningContact(
            _contactSelector.selectedContact.contact.id);
        _setup(Controller.Widget.contactCalendar, cmd);
      }
    }
  }

  /**
   * Close the widget and cancel edit/create calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void _close() {
    _ui.reset();
    window.history.back();
  }

  /**
   * Delete the calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void _delete(ORModel.CalendarEntry loadedEntry) {
    Function reInstateDeletedEntry;

    if (_entryOwner is ORModel.OwningContact) {
      reInstateDeletedEntry = _contactCalendar.preDeleteEntry(loadedEntry);
    } else {
      reInstateDeletedEntry = _receptionCalendar.preDeleteEntry(loadedEntry);
    }

    _calendarController
        .deleteCalendarEvent(_ui.loadedEntry, _entryOwner)
        .then((_) {
      _log.info('${loadedEntry} successfully deleted from database');
      _popup.success(
          _langMap[Key.calendarEditorDelSuccessTitle], 'ID ${loadedEntry.id}');
    }).catchError((error) {
      _log.shout('Could not delete calendar entry ${loadedEntry}');
      _popup.error(
          _langMap[Key.calendarEditorDelErrorTitle], 'ID ${loadedEntry.id}');
      reInstateDeletedEntry();
    });

    _close();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onCtrlE.listen((_) => _activateMe(Controller.Cmd.edit));
    _hotKeys.onCtrlK.listen((_) => _activateMe(Controller.Cmd.create));

    _ui.onCancel.listen((MouseEvent _) => _close());
    _ui.onDelete.listen((MouseEvent _) async => await _delete(_ui.loadedEntry));
    _ui.onSave.listen((MouseEvent _) async => await _save(_ui.harvestedEntry));
  }

  /**
   * Save the calendar entry.
   *
   * Clear the form when done, and then navigate one step back in history.
   */
  void _save(ORModel.CalendarEntry entry) {
    Function removeUnsavedElement;

    if (_entryOwner is ORModel.OwningContact) {
      removeUnsavedElement = _contactCalendar.unsavedEntry(entry);
    } else {
      removeUnsavedElement = _receptionCalendar.unsavedEntry(entry);
    }

    _calendarController
        .saveCalendarEvent(entry, _entryOwner)
        .then((ORModel.CalendarEntry savedEntry) {
      _log.info('${savedEntry} successfully saved to database');
      _popup.success(
          _langMap[Key.calendarEditorSaveSuccessTitle], 'ID ${savedEntry.id}');
    }).catchError((error) {
      ORModel.CalendarEntry loadedEntry = _ui.loadedEntry;
      _log.shout('Could not save calendar entry ${loadedEntry}');
      _popup.error(
          _langMap[Key.calendarEditorSaveErrorTitle], 'ID ${loadedEntry.id}');
      removeUnsavedElement();
    });

    _close();
  }

  /**
   * Render the widget with the [calendarEntry].
   */
  void _render(ORModel.CalendarEntry calendarEntry) {
    _ui.calendarEntry = calendarEntry;
  }

  /**
   * Set the [_ui.authorStamp]. This is populated with data from the latest
   * calendar entry change object for [entryId].
   */
  Future _setAuthorStamp(ORModel.CalendarEntry entry) async {
    ORModel.User user;
    try {
      user = await _userController.get(entry.lastAuthorId);
    } catch (error) {
      user = new ORModel.User.empty()..name = 'uid ${entry.lastAuthorId}';
    }
    _ui.authorStamp(user.name, entry.touched);
  }

  /**
   * Setup the widget accordingly to where it was opened from. [from] MUST be
   * the [Controller.Widget] that activated CalendarEditor.
   *
   * [from] decides which calendar to create/edit entries for.
   */
  void _setup(Controller.Widget from, Controller.Cmd cmd) {
    ORModel.CalendarEntry entry;

    switch (from) {
      case Controller.Widget.contactCalendar:
        if (cmd == Controller.Cmd.edit) {
          entry = _contactCalendar.selectedCalendarEntry;

          if (entry.id == ORModel.CalendarEntry.noId) {
            entry = _contactCalendar.firstCalendarEntry;
          }

          if (entry.id != ORModel.CalendarEntry.noId) {
            _ui.headerExtra =
                '(${_langMap[Key.editDelete]} ${_contactSelector.selectedContact.contact.name})';
            _setAuthorStamp(entry);

            _render(entry);

            _navigateToMyDestination();
          }
        } else {
          entry = new ORModel.CalendarEntry.empty()
            ..start = new DateTime.now()
            ..stop = new DateTime.now().add(new Duration(hours: 1))
            ..content = '';

          _ui.headerExtra =
              '(${_langMap[Key.editorNew]} ${_contactSelector.selectedContact.contact.name})';
          _ui.authorStamp(null, null);

          _render(entry);

          _navigateToMyDestination();
        }
        break;
      case Controller.Widget.receptionCalendar:
        if (cmd == Controller.Cmd.edit) {
          entry = _receptionCalendar.selectedCalendarEntry;

          if (entry.id == ORModel.CalendarEntry.noId) {
            entry = _receptionCalendar.firstCalendarEntry;
          }

          if (entry.id != ORModel.CalendarEntry.noId) {
            _ui.headerExtra =
                '(${_langMap[Key.editDelete]} ${_receptionSelector.selectedReception.name})';
            _setAuthorStamp(entry);

            _render(entry);

            _navigateToMyDestination();
          }
        } else {
          entry = new ORModel.CalendarEntry.empty()
            ..start = new DateTime.now()
            ..stop = new DateTime.now().add(new Duration(hours: 1))
            ..content = '';

          _ui.headerExtra =
              '(${_langMap[Key.editorNew]} ${_receptionSelector.selectedReception.name})';
          _ui.authorStamp(null, null);

          _render(entry);

          _navigateToMyDestination();
        }
        break;
      default:

        /// No valid initiator. Go home.
        _navigate.goHome();
        break;
    }
  }
}
