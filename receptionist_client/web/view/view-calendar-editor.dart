part of view;

class CalendarEditor extends ViewWidget {
  Place                 _myPlace;
  UICalendarEditor      _ui;

  CalendarEditor(UICalendarEditor this._ui, this._myPlace) {
    registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  void cancel(_) {
    /// TODO (TL):
    /// Clear form.
    /// Set focusElement to default.
    /// Navigate away (history.back perhaps??)
    window.history.back();
    print('view.CalendarEditor._cancel not fully implemented');
  }

  void delete(_) {
    /// TODO (TL):
    /// Delete calendar entry.
    /// Call _cancel().
    print('view.CalendarEditor._delete not fully implemented');
  }

  @override void onBlur(Place place){
    /// Cleanup stuff
  }

  @override void onFocus(Place place){
    switch(place.widget) {
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

  void registerEventListeners() {
    /// TODO (TL): On navigation to this widget:
    /// Figure out whether I got started from contact or reception calendar.
    /// Figure out whether this is a new calendar entry or an edit?
    /// If new: Add "now" data to the widget.
    /// If edit: Add data from the calendar entry to the widget.
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onTab     .listen(handleTab);
    _hotKeys.onShiftTab.listen(handleShiftTab);
    _hotKeys.onEsc     .listen(cancel);

    _ui.onCancel.listen(cancel);
    _ui.onDelete.listen(delete);
    _ui.onSave  .listen(save);
  }

  void save(_) {
    /// TODO (TL):
    /// Validate input data
    /// Save calendar entry.
    /// Call _cancel().
    print('view.CalendarEditor._save not fully implemented');
  }
}
