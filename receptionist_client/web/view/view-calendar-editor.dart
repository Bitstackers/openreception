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
  final ui_model.UIContactCalendar _contactCalendar;
  final controller.Calendar _calendarController;
  final ui_model.UIContactSelector _contactSelector;
  model.Owner _entryOwner;
  final Map<String, String> _langMap;
  final Logger _log = new Logger('$libraryName.CalendarEditor');
  final controller.Destination _myDestination;
  final controller.Popup _popup;
  final ui_model.UIReceptionCalendar _receptionCalendar;
  final ui_model.UIReceptionSelector _receptionSelector;
  final ui_model.UICalendarEditor _uiModel;
  final controller.User _userController;

  /**
   * Constructor
   */
  CalendarEditor(
      ui_model.UICalendarEditor this._uiModel,
      controller.Destination this._myDestination,
      ui_model.UIContactCalendar this._contactCalendar,
      ui_model.UIContactSelector this._contactSelector,
      ui_model.UIReceptionCalendar this._receptionCalendar,
      ui_model.UIReceptionSelector this._receptionSelector,
      controller.Calendar this._calendarController,
      controller.Popup this._popup,
      controller.User this._userController,
      Map<String, String> this._langMap) {
    _ui.setHint('Esc | ctrl+backspace | ctrl+s ');

    _observers();
  }

  @override
  controller.Destination get _destination => _myDestination;
  @override
  void _onBlur(controller.Destination _) {}
  @override
  void _onFocus(controller.Destination _) {}
  @override
  ui_model.UICalendarEditor get _ui => _uiModel;

  /**
   * Activate this widget if it's not already activated.
   *
   * Sets the entry owner.
   */
  void _activateMe(controller.Cmd cmd) {
    if (_receptionSelector.selectedReception != model.Reception.noReception) {
      if (_receptionCalendar.isFocused) {
        _entryOwner = new model.OwningReception(
            _receptionSelector.selectedReception.id);
        _setup(controller.Widget.receptionCalendar, cmd);
      } else {
        _entryOwner = new model.OwningContact(
            _contactSelector.selectedContact.contact.id);
        _setup(controller.Widget.contactCalendar, cmd);
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
  void _delete(model.CalendarEntry loadedEntry) {
    Function reInstateDeletedEntry;

    if (_entryOwner is model.OwningContact) {
      reInstateDeletedEntry = _contactCalendar.preDeleteEntry(loadedEntry);
    } else {
      reInstateDeletedEntry = _receptionCalendar.preDeleteEntry(loadedEntry);
    }

    _calendarController
        .deleteCalendarEvent(_ui.loadedEntry, _entryOwner)
        .then((_) {
      _log.info('$loadedEntry successfully deleted from database');
      _popup.success(
          _langMap[Key.calendarEditorDelSuccessTitle], 'ID ${loadedEntry.id}');
    }).catchError((error) {
      _log.shout('Could not delete calendar entry $loadedEntry');
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

    _hotKeys.onCtrlE.listen((_) => _activateMe(controller.Cmd.edit));
    _hotKeys.onCtrlK.listen((_) => _activateMe(controller.Cmd.create));

    _ui.onCancel.listen((MouseEvent _) => _close());
    _ui.onDelete.listen((MouseEvent _) async => await _delete(_ui.loadedEntry));
    _ui.onSave.listen((MouseEvent _) async => await _save(_ui.harvestedEntry));
  }

  /**
   * Save the calendar entry.
   *
   * Clear the form when done, and then navigate one step back in history.
   */
  void _save(model.CalendarEntry entry) {
    Function removeUnsavedElement;

    if (_entryOwner is model.OwningContact) {
      removeUnsavedElement = _contactCalendar.unsavedEntry(entry);
    } else {
      removeUnsavedElement = _receptionCalendar.unsavedEntry(entry);
    }

    _calendarController
        .saveCalendarEvent(entry, _entryOwner)
        .then((model.CalendarEntry savedEntry) {
      _log.info('$savedEntry successfully saved to database');
      _popup.success(
          _langMap[Key.calendarEditorSaveSuccessTitle], 'ID ${savedEntry.id}');
    }).catchError((error) {
      model.CalendarEntry loadedEntry = _ui.loadedEntry;
      _log.shout('Could not save calendar entry $loadedEntry');
      _popup.error(
          _langMap[Key.calendarEditorSaveErrorTitle], 'ID ${loadedEntry.id}');
      removeUnsavedElement();
    });

    _close();
  }

  /**
   * Render the widget with the [calendarEntry].
   */
  void _render(model.CalendarEntry calendarEntry, bool isNew) {
    _ui.setCalendarEntry(calendarEntry, isNew);
  }

  /**
   * Set the `authorStamp` of [_ui]. This is populated with data from the latest
   * calendar entry change object for [entry].
   */
  Future _setAuthorStamp(model.CalendarEntry entry) async {
    model.User user;
    try {
      user = await _userController.get(entry.lastAuthorId);
    } catch (error) {
      user = new model.User.empty()..name = 'uid ${entry.lastAuthorId}';
    }
    _ui.authorStamp(user.name, entry.touched);
  }

  /**
   * Setup the widget accordingly to where it was opened from. [from] MUST be
   * the [controller.Widget] that activated CalendarEditor.
   *
   * [from] decides which calendar to create/edit entries for.
   */
  void _setup(controller.Widget from, controller.Cmd cmd) {
    model.CalendarEntry entry;

    switch (from) {
      case controller.Widget.contactCalendar:
        if (cmd == controller.Cmd.edit) {
          entry = _contactCalendar.selectedCalendarEntry;

          if (entry.id == model.CalendarEntry.noId) {
            entry = _contactCalendar.firstCalendarEntry;
          }

          if (entry.id != model.CalendarEntry.noId) {
            _ui.headerExtra =
                '(${_langMap[Key.editDelete]} ${_contactSelector.selectedContact.contact.name})';
            _setAuthorStamp(entry);

            _render(entry, false);

            _navigateToMyDestination();
          }
        } else {
          entry = new model.CalendarEntry.empty()
            ..start = new DateTime.now()
            ..stop = new DateTime.now().add(new Duration(hours: 1))
            ..content = '';

          _ui.headerExtra =
              '(${_langMap[Key.editorNew]} ${_contactSelector.selectedContact.contact.name})';
          _ui.authorStamp(null, null);

          _render(entry, true);

          _navigateToMyDestination();
        }
        break;
      case controller.Widget.receptionCalendar:
        if (cmd == controller.Cmd.edit) {
          entry = _receptionCalendar.selectedCalendarEntry;

          if (entry.id == model.CalendarEntry.noId) {
            entry = _receptionCalendar.firstCalendarEntry;
          }

          if (entry.id != model.CalendarEntry.noId) {
            _ui.headerExtra =
                '(${_langMap[Key.editDelete]} ${_receptionSelector.selectedReception.name})';
            _setAuthorStamp(entry);

            _render(entry, false);

            _navigateToMyDestination();
          }
        } else {
          entry = new model.CalendarEntry.empty()
            ..start = new DateTime.now()
            ..stop = new DateTime.now().add(new Duration(hours: 1))
            ..content = '';

          _ui.headerExtra =
              '(${_langMap[Key.editorNew]} ${_receptionSelector.selectedReception.name})';
          _ui.authorStamp(null, null);

          _render(entry, true);

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
