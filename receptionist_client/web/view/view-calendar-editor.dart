part of view;

/**
 * TODO (TL): Comment
 */
class CalendarEditor extends ViewWidget {
  final Model.UIContactCalendar   _contactCalendar;
  final Controller.Destination    _myDestination;
  final Model.UIReceptionCalendar _receptionCalendar;
  final Model.UICalendarEditor    _ui;

  /**
   * Constructor
   */
  CalendarEditor(Model.UICalendarEditor this._ui,
                 Controller.Destination this._myDestination,
                 Model.UIContactCalendar this._contactCalendar,
                 Model.UIReceptionCalendar this._receptionCalendar) {
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_) {}

  /**
   * When we get focus, figure out where from we were called. If we weren't
   * called from anywhere ie. the [destination].from.widget is null, then
   * navigate to home.
   */
  @override void onFocus(Controller.Destination destination){
    if(destination.from != null) {
      setup(destination.from.widget, destination.cmd);
    } else {
      _navigate.goHome();
    }
  }

  /**
   * Cancel edit/create calendar entry.
   *
   * Clear the form and navigate one step back in history.
   */
  void cancel(_) {
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
  void delete(_) {
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

    _ui.onCancel.listen(cancel);
    _ui.onDelete.listen(delete);
    _ui.onSave  .listen(save);
  }

  /**
   * Save the calendar entry.
   *
   * Clear the form when done, and then navigate one step back in history.
   */
  void save(_) {
    /// TODO (TL):
    /// Validate input data
    /// Save calendar entry.
    /// Call _cancel().
    print('view.CalendarEditor._save not fully implemented');
  }

  /**
   * Render the widget with [calendarEntry].
   */
  void render(Model.CalendarEntry calendarEntry) {
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
  void setup(Widget initiator, Cmd cmd) {
    switch(initiator) {
      case Widget.ContactCalendar:
        if(cmd == Cmd.EDIT) {
          _ui.headerExtra = '(ret/slet)';
          render(_contactCalendar.selectedCalendarEntry);
        } else {
          _ui.headerExtra = '(ny)';
          /// TODO (TL): Create a real calendar entry, with date/time fields set.
          render(new Model.ContactCalendarEntry(42, 2));
        }
        break;
      case Widget.ReceptionCalendar:
        if(cmd == Cmd.EDIT) {
          _ui.headerExtra = '(ret/slet)';
          render(_receptionCalendar.selectedCalendarEntry);
        } else {
          _ui.headerExtra = '(ny)';
          /// TODO (TL): Create a real calendar entry, with date/time fields set.
          render(new Model.ReceptionCalendarEntry(42));
        }
        break;
      default:
        /// No valid initiator. Go home.
        _navigate.goHome();
        break;
    }
  }
}
