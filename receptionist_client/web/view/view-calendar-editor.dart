part of view;

class CalendarEditor extends ViewWidget {
  final Model.UIContactCalendar   _contactCalendar;
  final Controller.Place          _myPlace;
  final Model.UIReceptionCalendar _receptionCalendar;
  final Model.UICalendarEditor    _ui;

  /**
   * Constructor
   */
  CalendarEditor(Model.UICalendarEditor this._ui,
                 this._myPlace,
                 Model.UIContactCalendar this._contactCalendar,
                 Model.UIReceptionCalendar this._receptionCalendar) {
    _ui.help = 'some help';

    _observers();
  }

  @override Controller.Place get myPlace => _myPlace;
  @override Model.UIModel    get ui      => _ui;

  @override void onBlur(_) {}

  /**
   * When we get focus, figure out where from we were called. If we weren't
   * called from anywhere ie. the place.from.widget is null, then navigate to
   * home.
   */
  @override void onFocus(Controller.Place place){
    if(place.from != null) {
      setup(place.from.widget);
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
    /// Navigate away (history.back perhaps??)
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

    _hotKeys.onEsc.listen(cancel);

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
   * Render the widget with a [CalendarEvent]. Note if the [CalendarEvent] is a
   * null event, then the widgets renders with its default values.
   */
  void render(CalendarEvent calendarEvent) {
    _ui.content = calendarEvent;
  }

  /**
   * Setup the widget accordingly to where it was opened from. [initiator] MUST
   * be the [Widget] that activated CalendarEditor.
   *
   * This widget is only ever opened from other widgets, and as such we need to
   * know who activated us, in order to properly know how to find and deal
   * with the calendar entry we're either editing or creating.
   */
  void setup(Widget initiator) {
    switch(initiator) {
      case Widget.ContactCalendar:
        render(_contactCalendar.selected);
        break;
      case Widget.ReceptionCalendar:
        render(_receptionCalendar.selected);
        break;
      default:
        /// No valid initiator. Go home.
        _navigate.goHome();
        break;
    }
  }
}
