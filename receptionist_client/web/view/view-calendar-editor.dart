part of view;

class CalendarEditor extends ViewWidget {
  Place                 _myPlace;
  UICalendarEditor      _ui;

  CalendarEditor(UICalendarEditor this._ui, this._myPlace) {
    registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  @override void onBlur(Place place) {}

  @override void onFocus(Place place){
    setup(place.from.widget);
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
    if(_ui.active) {
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

  void registerEventListeners() {
    /// TODO (TL): On navigation to this widget:
    /// Figure out whether I got started from contact or reception calendar.
    /// Figure out whether this is a new calendar entry or an edit?
    /// If new: Add "now" data to the widget.
    /// If edit: Add data from the calendar entry to the widget.
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onEsc     .listen(cancel);

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
        print('CalendarEditor opened from ContactCalendar');
        break;
      case Widget.ReceptionCalendar:
        print('CalendarEditor opened from ReceptionCalendar');
        break;
      default:
        /// TODO (TL): Do something sane here...
        break;
    }
  }
}
